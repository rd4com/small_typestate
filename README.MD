# 💡 small typestate pattern POC in mojo 🔥
Here is a small one,
keep in mind that alloc could fail, this implementation do no cover that!

Hope this gives an idea on how parameters can do useful things,
it is just a small example.


```mojo
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
```

Note: there is a small auto-free system like `box` just to give an idea!

Was not sure if `__moveinit__` on `@register_passable` would call `__del__`

on other. So there is a small struct to test that.


