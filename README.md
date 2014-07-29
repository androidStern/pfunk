# PFUNK

> Flexible type annotations as an afterthought

## Installation


`$ npm i pfunk`


## Example

```
{pfunk} = require './sig.coffee'

add = (a,b)-> a + b

pAdd = pfunk(add)


###
 * Lets make a version of add that only accepts Numbers
###

numberNumberAdd = pAdd.withSignature("Number", "Number")

```

And when we give it the correct arguments...
```
console.log numberNumberAdd(1, 1)
#=> 2
```
But if one of the arguments doesn't satisfy the signature...
```
console.log numberNumberAdd("1", 1)
#=> Error ... KABOOM~!!
```
---
We can use the same `pAdd` function to define a different
version that only accepts strings.

```

stringStringAdd = pAdd.withSignature("String", "String")
```

as expected, it works with strings...
```
console.log stringStringAdd("a", "b")
#=> ab
```

but not numbers
```
console.log stringStringAdd(1, 1)
#=> Error ... EXPLOSION~~~~~!!!!!!
```

---


Finally,  you aren't limited to the type annotations provided by pfunk. You can define your own
`types` using pfunk.registerType. Pfunk types are just predicate functions that return
true if a give value should be considered to be of type `x` and false otherwise.
Given this definition, let's define two new types; Long_String, anything with a length
property greater than 3, and Short_String, anything with a length less than three.

```
longerThan3 = (thing)-> thing.length > 3
shorterThan3 = (thing)-> thing.length < 3

pfunk.registerType("Long_Thing", longerThan3)
pfunk.registerType("Short_Thing", shorterThan3)

```


Now we can use our new types to anotate any pfunk function.
but first, lets take this opportunity showcase another nifty feature of pfunk...

Imagine we want a function that concatenates two strings, but only if the
first string is a `Long_Thing` and the second was a `Short_Thing`.
We already have a function that joins strings, stringStringAdd, so we should try
to reuse that if we can. What we want is to further specify the signature
of stringStringAdd such that it not only restricts its arguments to strings, but
also ensures that the first string as a `Long_Thing` and the seccond is a `Short_Thing`.
Since stringStringAdd is already a pfunk function, adding aditional signature constraints
is as easy as calling .withSignature. Check it out:
```
longString_shortString_Add = stringStringAdd.withSignature("Long_Thing", "Short_Thing")
```
and given a Long_Thing and a Short_Thing...
```
console.log longString_shortString_Add("abcd", "a")
#=> abcda ... Awesome it does the right thing.
```
But if the signature doesn't match, like for example if the first argument was
actually a Short_Thing:
```
console.log longString_shortString_Add("ab", "a")
#=> Error ... This fails because "ab" isn't long enough.
```

and now the moment of truth. Lets try something with a length property greater than 3

```
LONG_ARRAY_THING = [1,2,3,4,5]

console.log longString_shortString_Add(LONG_ARRAY_THING, "a")
#=> Error ...
```

LONG_ARRAY_THING's length is > 3 but since longString_shortString_Add is built on top of
stringStringAdd, it `inherits` (excuse the oop) stringStringAdd's pre-condition that both arguments
must be strings and thus fails.