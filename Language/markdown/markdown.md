#Markdown语法  
  
##一、标题  
###1.用`#`标记  
**代码**  
```
#一级标题  
##二级标题
```
**效果**
> 
#一级标题
##二级标题

###2.用=和-标记
**代码**
```
一级标题
====
二级标题
----
```
**效果**
> 
一级标题
====
二级标题
----


##二、标记
**代码**
```
这里是`markdown`的教程
```
__效果__
> 这里是`markdown`的教程


##三、强调
**代码**

	***加粗+倾斜***
	**加粗**  __加粗__
	*斜体*    _斜体_
	~~删除~~ 
**效果**
> ***加粗+倾斜***  
**加粗**  
*斜体*  
~~删除~~


##四、续表
###1.有序
**代码**

	1. one
	2. two
	3. three

**效果**
> 
1. one
2. two
3. three

##2.无序
**代码**

	* one
	* two
	* three

**效果**
> 
* one
* two
* three

##3.嵌套序表
**代码**

	1. one
		1. one-1
		2. one-2 
	2. two

**效果**
> 
1. one
	1. one-1
	2. one-2 
2. two

##4.嵌套代码块
**代码**

	1. one
		
		var a = 10;

**效果**
> 
1. one
		
		var a = 10;


##五、引用
**代码**
```
> 单行引用 

> 多行引用
> 多行应用
> 多行引用

> 层次嵌套
>> 层次嵌套
>>> 层次嵌套
```
**效果**
> 单行引用
>> 多行引用
>>> 层次嵌套



##六、代码块
###1.(```)
**代码**
```
	```
	<div>
		<div></div>
	</div>
	```
```
**效果**
```
<div>
	<div></div>
</div>
```
###2.(Tab)
**代码**

	我是文字。。。  
		<div>
			<div></div>
		</div>
**效果**

	我是文字。。。
		<div>
			<div></div>
		</div>
###3.语法高亮
**代码**

	```javascript
	var num = 0;
	for(var i = 0;i < 5; i++{
		num+=i;
	}
	console.log(num);
	```
**效果**
```
var num = 0;
for(var i = 0;i < 5; i++{
	num+=i;
}
console.log(num);
```


##七、链接
###1.内链式
**代码**

	[百度](http://www.baidu.com“百度一下”)
**效果**
> [百度](http://www.baidu.com“百度一下”)

###2.引用式
**代码**

	[百度][2]
	[2]:http://www.baidu.com "百度一下"
**效果**
> [百度][2]
[2]:http://www.baidu.com "百度一下"  
>

##八、图片
###1.内链式
**代码**

	![](https://github.com/smapley/book/blob/master/markdown/01.png?raw=true '描述')
**效果**
> 
![](https://github.com/smapley/book/blob/master/markdown/01.png?raw=true '描述')

###2.引用式
**代码**

	![name][01]
	[01]:.https://github.com/smapley/book/blob/master/markdown/01.png?raw=true '描述'
**效果**
> ![name][01]
[01]:https://github.com/smapley/book/blob/master/markdown/01.png?raw=true '描述'

###3.带有链接
**代码**

	内链式：
	[![](https://github.com/smapley/book/blob/master/markdown/01.png?raw=true '百度')](http://www.baidu.com)
	引用式：
	[![](https://github.com/smapley/book/blob/master/markdown/01.png?raw=true '百度')][5]
	[5]: http://www.baidu.com
**效果**
> [![](https://github.com/smapley/book/blob/master/markdown/01.png?raw=true '百度')](http://www.baidu.com)
> 
> [![](https://github.com/smapley/book/blob/master/markdown/01.png?raw=true '百度')][5]
[5]: http://www.baidu.com
>


##九、表格
**代码**  
```
\\	|    a    |       b       |      c     |
\\	|:-------:|:------------- | ----------:|
\\	|   居中  |     左对齐    |   右对齐   |
\\	|=========|===============|============|

```
**效果**
> 
|    a    |       b       |      c     |
|:-------:|:------------- | ----------:|
|   居中  |     左对齐    |   右对齐   |
|=========|===============|============|



