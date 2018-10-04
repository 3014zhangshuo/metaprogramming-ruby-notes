## 概念：
### 类宏（Class Macro）
> 在类定义中使用类方法

```
class C; end

class << C
  def my_macro(arg)
    "my_macro(#{arg}) called"
  end
end

class C
  my_macro :x
end
```
### 内核方法（Kernel Method）
> 在 Kernel 模块中定义一个方法，使得所有对象都可使用。

```
module Kernel
  def a_method
    "a Kernal method"
  end
end

a_method # => "a Kernal method"
```

## 目标
> 编写一个类宏，类似于 `attr_accessor`，但是创建属性的时候要先通过校验，方法名为 `attr_checked`。

```
class Person
  include CheckedAttributes

  attr_checked :age do |v|
    v >= 18
  end
end

me = Person.new
me.age = 39
me.age = 12 # raise error
```

## Code Plan

* 使用 `eval` 方法编写一个名为 `add_checked_attributes`的内核方法
* 重构 `add_checked_attributes` 方法，去掉 `eval` 方法
* 通过代码块来校验属性
* 把 `add_checked_attributes` 方法修改为名为 `attr_checked` 的类宏，它对所有类都可用。
* 写一个模块，通过钩子方法为定义的类添加 `attr_checked` 方法。

## Kernal#eval

> 从底层看，代码只是文本而已。

```
array = [10, 20]
element = 30
eval("array << element")
```

## Binding Objects
> `Binding` 就是一个用对象表示的完整的作用域。
> 可以通过创建 `Binding` 对象来捕获并带走当前的作用域。

```
class MyClass
  def my_method
    @x = 1
    binding
  end
end

b = MyClass.new.my_method
```

`Binding` 对象可以看做比块更纯净的闭包，它们只包含作用域而不包含代码。eval方法可以给它传递一个 `Binding` 对象作为额外的参数，代码就可以在这个`Binding`对象所携带的作用域里面执行

```
eval("@x", b)
```

`TOPLEVEL_BINDING` 代表顶级作用域的 `Binding` 对象，
可以在程序的任何地方访问它。

```
class AnotherClass
  def my_method
    eval "self", TOPLEVEL_BINDING
  end
end

AnotherClass.new.my_method # => mainz
```

## The Trouble with eval
