# The Nuni Programming Language
## Hello World
```
let mystr = "Hello World"
println mystr
```
```
Hello World
```

## Examples
### Basic arithmetic
> ⚠️ **_NOTE:_**  Make sure to always write arithemtic operations together (without spaces inbetween!). 
```
println 2+5   //  7
println 2-5   // -3
println 2*5   // 10 
println 2/5.0 // 0.4 (atleast one needs to be a float in order to show decimal precision)
println 2/5	  // 0
println 2%5   // 2
println 2**5  // 32
```

### defining variables
```
let favNumber = 1/7		 // -> mutable
let PI = 3.14159265359 // -> immutable (constant)
let PI = 3.141				 // let's you change variable but sends warning (ruby-style)
```
```
./Examples/variables.rb:3: warning: already initialized constant PI
./Examples/variables.rb:2: warning: previous definition of PI was here
```

### defining and using (single-line) functions
Currently the definition of single-line functions relies on the usage of ruby syntax in the
scriptblock `{}`. This will be changed as soon as possible so that we can only use `nuni` syntax!
```
fn add = x, y { sum = x+y; sum; } // single line function definition
add 2, 5

println "Calculating.."
let test = 7 + (add 2, 5)
println test
```
```
Calculating..
14
```

## Future ideas
- MULTI-LINE function declaration with nuni syntax
```
fn add = x, y {
	x+y
}

let sum = add 2, 5 // => 7
```

- SINGLE-LINE function declaration with nuni syntax
```
fn add = x, y { let sum = x+y; sum }
let sum = add 2, 5
println sum // => 7
```
