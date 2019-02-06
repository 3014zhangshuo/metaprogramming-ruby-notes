# Chapter 4 代码块

> 代码块源自LISP这样的函数式编程语言

## 代码块是闭包（Blocks Are Closures）

* 运行代码需要一个执行环境：局部变量，实例变量，self等。

* 这些东西都是绑定在对象上的名字，简称为`binding`。

* 代码块之所以可以运行，是因为它既包含代码，也包含一组绑定。

* 定义一个块时，它会获取环境中的绑定。当块被传给一个方法时，它会带着这些绑定一块进入该方法。

### * Blocks Binding

```
def my_method
  x = 'GoodBye'
  yield('cruel')
end

x = 'Hello'
my_method { |y| "#{x}, #{y} world" } # => "Hello, cruel world"
```

创建代码块时，同时获得局部绑定，然后把代码块连同绑定传给一个方法。虽然方法中也定义了相同名称的变量，但方法中的x对这个代码块来说是不可见的。

### * 外部无法访问代码块内部变量

```
def just_yield
  yield
end

top_level_variable = 1

just_yield do
  top_level_variable += 1
  local_to_block = 1
end

top_level_variable  # => 2
local_to_block      # => Error!
```

## 作用域（Scope）

```
v1 = 1

class MyClass
  v2 = 2
  local_variables # => [:v2]

  def my_method
    v3 = 3
    local_variables # => [:v3]
  end
  local_variables # => [:v2]
end

obj = MyClass.new
obj.my_method   # => [:v3]
obj.my_method   # => [:v3]
local_variables # => [:v1, :obj]
```

程序切换作用域，有些的绑定就会被新的绑定所取代。并不是所有绑定都会被取代，比如说调用同一个对象的另一个方法，实例变量在调用过程中就始终存在于作用域里。

### * 作用域门

程序会在三个地方关闭前一个作用域，同时打开一个新的作用域：

* 类定义
* 模块定义
* 方法

### * 扁平化作用域

```
my_var = "Success"

class MyClass
  # expect printf my_var

  def my_method
    # and there
  end
end
```

将`class`关键字替换为非作用域门的东西，例如调用方法，使用动态方法传过`def`的作用域门：

```
my_var = "Success"

MyClass = Class.new do
  printf "#{my_var} in the class definition"

  define_method :my_method do
    "#{my_var} in the method"
  end
end
```

### * 共享作用域

一组方法共享一个变量，但又不希望其他方法访问这个变量。
```
def define_methods
  shared = 0
  Kernel.send :define_method, :counter do
    shared
  end

  Kernel.send :define_method, :inc do |x|
    shared += x
  end
end

define_methods

counter # => 0
inc 4
counter # => 4
```

## BasicObject#instance_eval

```
class MyClass
  def initialize
    @v = 1
  end
end

obj = MyClass.new
obj.instance_eval do
  p self # => MyClass instance object
  @v     # => 2
end
```

代码块的接受者会变成`self`，所有他可以访问接受者的实例变量和私有方法。即使`instance_eval`方法修改了`self`对象，传给`instance_eval`方法的代码块仍然可以看到在它定义时的那些绑定：

```
v = 2
obj.instance_eval { @v = v }
obj.instance_eval { @v } # => 2
```

### * instance_exec
```
class C
  def initialize
    @x = 1
  end
end

class D
  def twisted_method
    @y = 2
    C.new.instance_eval { "@x: #{@x}, @y: #{@y}" }
  end
end

D.new.twisted_method # => "@x: 1, @y: "
```

##### 上面代码最终想输出`@x: 1, @y: 2`，出问题的原因为：

&ensp;&ensp;实例变量获取于当前对象`self`。`instance_eval`方法把接受者当做当前对象`self`时，代码块中的实例变量仅从`C.new`中获取，因此方法的调用者的实例变量就落在作用域外部了。

##### instance_exec 允许对代码块传入参数：
```
class C
  def initialize
    @x = 1
  end
end

class D
  def twisted_method
    @y = 2
    C.new.instance_exec(@y) { |y| "@x: #{@x}, @y: #{y}" }
  end
end

D.new.twisted_method # => "@x: 1, @y: 2"
```

## 可调用对象

打包代码三种方法：
* 使用proc，proc是由块转换来的对象。
* 使用lambda，它是proc的变种。
* 使用方法（method）。

### Proc对象

> 代码块不是对象，如果想存储一个块供以后执行，那么你就需要一个对象。

```
inc = Proc.new { |x| x + 1 }
inc.call(4) # => 5
```
Ruby为了解决这个问题，提供了`Proc`类，可以把代码块转换为可调用的对象。

#### Ruby有两个内核方法可以把块转换为`Proc`对象：

##### proc:
```
p = proc { |x| x + 1 }
p.class # => Proc
```

##### lambda:
```
l = lambda { |x| x + 1 }
l.class # => Proc
```
lambda还可以用一种`->`stabby操作符来创建`l = -> (x) { x + 1 }`

#### &操作符

代码块就像是方法的`匿名参数`，大多数情况可以用`yield`运行。但有些情况`yield`就无能为力了：

* 把代码块传递给另一个方法。
* 把代码块转换成Proc。

这两种情况你都要给代码块一个名字，将它附加到一个绑定上。你可以给这个方法添加一个特殊的参数，这个参数必须是参数列表的最后一个。并以`&`符号开头。

```
def math(a, b)
  yield(a, b)
end

def do_math(a, b, &operation)
  math(a, b, &operation)
end

do_math(2, 3) { |x, y| x * y } # => 6
```

##### &操作符可以来回转换代码块和proc
* block to proc
  ```
  def my_method(&the_proc)
    the_proc
  end

  p = my_method { |name| "hello #{name}" }
  p.class # => Proc
  p.call('world') # => "hello world"
  ```
* proc to block
  ```
  def my_method(greeting)
    "#{greeting} #{yield}"
  end

  my_proc = proc { "Dave" }
  my_method("hello", &my_proc) # => "hello Dave"
  ```

#### proc vs lambda
* return关键字
  * 在proc中，return并不是从proc中返回，而是从定义proc的作用域返回。
  * 在lambda中，return仅仅表示从这个lambda中返回。
* lambda会检查传入参数的数量

  ```
  def double
    p = Proc.new { return 10 }
    result = p.call
    return p * 2 # Never execute
  end

  double # => 10
  ```

  ```
  def double(callable_object)
    callable_object.call * 2
  end
  ```

tips: 可以使用`Proc#lambda?`判断是proc还是lambda。

### Method

```
class MyClass
  def initialize(value)
    @x = value
  end

  def my_method
    @x
  end
end

object = MyClass.new(1)
m = object.method :my_method
m.class # => Method
m.call  # => 1
p = m.to_proc
p.class # => Proc
```
tips: lambda在定义它的作用域中执行，method对象会在它自身所在对象的作用域中执行。

#### UnboundMethod

##### 获取自由方法
```
module MyModule
  def my_method
    24
  end
end

unbound = MyModule.instance_method :my_method
unbound.class # => UnboundMethod
```

##### 重新绑定

```
bind = unbound.bind(String.new)
bind.call # => 24

String.send(:define_method, :another_method, unbound)
"test".another_method # => 24
```
