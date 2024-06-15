# note: alloc could fail, this do not implement thoses eventualities
@register_passable
struct Heap[ T: AnyType, Allocated:Bool = False, Initialized: Bool = False]:
    var _heap: UnsafePointer[T]
    fn __init__(
        inout self: Heap[
            T,False,False
        ]
    ):
        self._heap = UnsafePointer[T]()

    fn allocate(
        owned self: Heap[
            T,False,False
        ]
    )-> Heap[T, True, False]:
        return Heap[T,True,False]{
            _heap: UnsafePointer[T].alloc(1)
        }
    
    fn initialize_by_move[T:Movable](
        owned self: Heap[
            T,True,False
        ],
        owned arg: T
    )-> Heap[T, True, True]:
        var tmp = Heap[T,True,True]{
            _heap: self._heap
        }
        self._heap = UnsafePointer[T]()
        tmp._heap.init_pointee_move(arg^)
        return tmp^
    
    fn replace_value_by_move[T:Movable](
        inout self: Heap[
            T,True,True
        ],
        owned arg: T
    ):
        self._heap[] = arg^

    fn move_value_out[T:Movable](
        owned self: Heap[
            T,True,True
        ]
    ) -> T:
        var tmp = self._heap.take_pointee()
        self._heap.free()
        self._heap = UnsafePointer[T]()
        return tmp^

    fn mut_ref[T:AnyType](
        inout self: Heap[T,True,True]
    )->ref[__lifetime_of(self)]T:
        return self._heap[]
    
    fn __del__(owned self):
        if self._heap == UnsafePointer[T](): 
            return
        else:
            @parameter
            if Initialized:
                self._heap.destroy_pointee()
            self._heap.free()
fn main():
    var a = Heap[Int, Allocated=False, Initialized=False]()
    var b = a^.allocate()
    var c = b^.initialize_by_move(1)
    c.replace_value_by_move(2)
    var d: Int = c^.move_value_out()

    var A = Heap[Int]().allocate().initialize_by_move(1)
    A.mut_ref() = 2
    var B: Int = A^.move_value_out()
    print(B)
    

    var X = MoveDelTest{x:1}
    var X2 = X^
    var X3 = X2^
    print(X3.x) #one __del__
@register_passable
struct MoveDelTest:
    var x: Int
    fn __del__(owned self): print("__del__")
