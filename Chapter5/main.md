# Chapter 5 Class Definitions

## The Current Class

* 在程序的顶层，当前类为`Object`，这是`main`对象所属的类。
* 在一个方法中，当前类就是当前对象的类。
* 当用`class`关键字打开一个类时，那个类成为当前类。

### class_eval
```
def add_method_to(a_class)
  a_class.class_eval do
    def m
      "hello"
    end
  end
end

add_method_to String
"adc".m # => hello
```
* 如果希望是打开一个对象，但不关心它是不是一个类，那么`instance_eval`就很好。
* 如果你想使用打开类的技巧修改类，那么 `class_eval`方法显然是更好的选择。

### class instance variables
* ruby 解释器假定所有的实例变量都属于当前对象 `self`。
* 一个类实例变量只可以被类本身所访问，而不能被类的实例或者子类所访问。

### Class Taboo
> 不使用`class`关键字，完成下面代码相同的功能

Q:
```
class MyClass < Array
  def my_method
    "hello!"
  end
end
```
A:
```
c = Class.new(Array) do
  def my_method
    "hello!"
  end
end
```
上面答案有了引用某个类的变量，但是这个类还是匿名的。类名只是一个常量而已，因此给它赋值。
```
MyClass = c
```
当你把匿名类的赋值给一个常量时，ruby知道你是想给这个类命名，它会对类说这是你的新名字，这个常量就表示这个Class，同时这个Class也就表示这个常量。

## Singleton Methods
* Class Method is Singleton Method

## Singleton Class
* ruby 方法的查找方法时先向右一步进入接受者的类，然后向上查找。
  ```
  class MyClass
    def my_method; end
  end

  obj = MyClass.new
  obj.my_method
  ```
  ruby会在MyClass类里面找到要调用的my_method方法。

* find singleton class

  ```
  obj = Object.new

  singleton_class = class << obj
    self
  end

  singleton_class.class # => Class
  obj.singleton_class 
  ```
* 每个单件类只有一个实例，单件类是对象的单件方法储存之处。

  ```
  def obj.my_singleton_method; end
  singleton_class.instance_methods.grep(/my_/)
  ```

#### 对象模型规则

1. 只有一种对象 - 要么是普通对象，要么是模块
2. 只有一种模块 - 可以是 普通模块 类 单件类
3. 只有一种方法 - 它存在于一个模块中，通常是一个类中。
4.
5. 除了`BasicObject`类没有超类，每个类有且只有一个祖先（要么是一个类，要么是一个模块）。这意味着任何类只有一条向上的，直到`BasicObject`的祖先链。
6. 一个对象的单件类的超类是这个对象的类；一个类的单件类的超类是这个类的超类的单件类

#### 单件类 和 instance_eval
`instance_eval`方法会修改`self`，而`class_eval`会对`self`和当前类都进行修改。其实`instance_eval`方法也会修改当前类，它会把当前类修改为接受者的单件类。

```
class MyClass; end

singleton_class = class << MyClass
  self
end

MyClass.instance_eval do
  def hello; end
end

singleton_class.instance_methods(false) # => [:hello]

MyClass.class_eval do
  def self.hi; end
end
```


## alias
* 环绕别名

```
class MyClass
  def my_method
    'my_method()'
  end

  alias_method :m, :my_method
end

obj = MyClass.new
obj.my_method
obj.m
```

```
class String
  alias_method :real_length, :length

  def length
    real_length > 5 ? 'long' : 'short'
  end
end

"War and Peace".length
"War and Peace".real_length
```
