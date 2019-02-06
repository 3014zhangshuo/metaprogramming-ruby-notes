# 对象模型（The Object Model）
## Open Classes

> 从某种意义上说，ruby的 `class` 关键字更像是一个作用域操作符，而不是类型声明语句。是的，它的确可以创建一个还不存在的类，但你可以把这当成是一个副作用。`class` 关键字的核心任务是把你带到类的上下文中，让你可以在里面定义方法。打开类又名猴子补丁`Monkeypatch`。

```
class D
  def x; 'x'; end
end

class D
  def y; 'y'; end
end

obj = D.new
obj.x
obj.y
```
上面的代码中，第一次提及`class D`时，还没有一个名为D的类存在，因此，Ruby开始着手定义这个类，并定义`x`方法。第二次提及`D`类时，它已经存在，Ruby就不再定义了。Ruby只是重新打开已存在的类，并为之定义`y`方法。

## Inside the object model
对象包含：
* 实例变量，可以通过`Object#instance_variables`查看。
* 方法，可以通过`Object#methods`查看。在Ruby中，一个对象并没有真正存放一组方法，在其内部，一个对象仅包含它的实例变量以及一个对自身类的引用。

### 类也是对象

像普通对象一样，类也可以通过引用来访问。变量可以像引用普通对象一样引用类`my_class = MyClass`，MyClass和my_class都是对同一个Class类的实例的引用，唯一的区别在于，my_class是一个变量，而MyClass是一个常量。类不过是对象而已，类名也就是常量。

### 常量（Constants）

#### 作用域

```
module MyModule
  MyConstant = 'Outer Constant'
  class MyClass
    MyConstant = 'Inner Constant'
  end
end
```
模块和类就像是目录，而常量则像是文件。只要不在同一个目录下，不同文件可以有相同的文件名。

#### 路径
```
MyModule::MyConstant          # => 'Outer Constant'
MyModule::MyClass::MyConstant # => 'Inner Constant'
```

绝对路径：

```
Y = 'a root-level Constant'
module M
  Y = 'a Constant in M'

  Y   # => 'a Constant in M'
  ::Y # => 'a root-level Constant'
end
```

#### 查询
* `Module.constants`返回程序中所有顶层的常量。
* `Module#constants`返回当前作用域的所有常量。
* 路径查询`Module.nesting`

```
module M
  class C
    module M2
      Module.nesting # => [M::C::M2, M::C, M]
    end
  end
end
```

## Ruby 对象模型
* 对象有一组实例变量和类的引用组成。
* 对象的方法存在于对象所属的类中（对类来说是实例方法）。
* 类本身是`Class`类的实例。类的名字只是一个常量。
* `Class`类是`Module`的子类，一个模块基本上就是由一组方法组成的包。类除了具有模块的特性之外，还可以被实例化（使用`new`方法），或者按一定的层次结构来组织（使用`superclass`方法）。
* 常量像文件系统一样，是按照树形结构组织的。其中，模块和类的名字扮演目录的角色，其他普通的常量则扮演文件的角色。
* 每个类都有一祖先链，这个链从每个类自己开始，向上直到`BasicObject`类结束。
* 调用方法时，Ruby首先向右找到接受者所属的类，然后向上查找祖先链，直到找到该方法或达到链的顶端为止。
* 在类中包含一个模块（使用`include`方法）时，这个模块会被插入祖先链中，位置在类的正上方；而使用`prepend`方法包含一个模块时，模块也会被插入祖先链中，位置在类的正下方。
* 调用一个方法时，接受者会扮演`self`的角色。
* 定义一个模块（或类）是，该模块也会扮演self的角色。
* 实例变量永远被认定为`self`的实例变量。
* 任何没有明确指定接受者的方法调用，都当做是调用`self`的方法。
* 细化（refine）就像在原来的类上添加一块补丁，而且他会覆盖正常的方法查找。此外，细化只在程序的部分区域生效：从`using`语句的位置开始，直到模块结束，或者直到文件结束。
