# Chapter 3 Methods

> 对每一次方法的调用，编译器都会检查接受对象是否有一个匹配的方法，这称之为静态检查（static type checking），这些语言被称为静态语言（static language）。如果调用对象中没有这个方法，编译器就会发出警告。而动态语言，则没有这样一个像警察一样的编译器，只有调用真正被执行的方法才会报错。

## 动态方法

> 调用一个方法实际上是给一个对象发送一条消息。

### 动态派发
```
class MyClass
  def my_method(arg)
    arg * 2
  end
end

obj = MyClass.new
obj.my_method(3) # => 6
```
这里可以使用`Object#send`方法来调用`MyClass#my_method`方法
```
obj.send(:my_method, 3) # => 6
```
在`send`方法里，你想调用的方法名变成了参数，这样就可以在代码运行的最后一行决定调用的方法，这个技巧就是动态派发。

### 动态方法

```
class MyClass
  define_method :my_method do |arg|
    arg * 2
  end
end

obj = MyClass.new
obj.my_method(3) # => 6
```
`define_method`方法允许在运行时决定方法的名字。

### method_missing
覆盖`method_missing`的方法同时也要复写`respond_to_missing?`

### Removing Methods

* `undef_method` 移除所有（包括继承而来的）方法
* `remove_method` 只删除接受者自己的方法，而保留继承来的方法
