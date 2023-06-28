# Nuni
## Hello World
```
let mystr = "Hello World"
println mystr
```

## Examples
### Hello World
```
let mystr = "Hello World"
println mystr // prints Hello world
println 1+2
```
```
Hello World
3
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
- MULTI-LINE function declaration
```
fn add = x, y {
	x+y
}

let sum = add 2, 5 // => 7
```

- SINGLE-LINE function declaration
```
fn add = x, y { let sum = x+y; sum }
let sum = add 2, 5
println sum // => 7
```
