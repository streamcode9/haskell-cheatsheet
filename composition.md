# Lego (IKEA rail way) philosophy
* all pieces are designed to be connected
* peices are reusable in differenct contexts
* you can construct new peice from two or more pieces and it still be meet 1 and 2

# Functions

```
input -> function => output
```

Input and output are also could be functions.
Parameter could be a function.

# Functions composition

```js
add1   = x => x + 1
time2  = x => x * 2
square = x => x * x
square(time2(add1(5)))
```

Piping. Azure pipeline.

```js
// 5 |> add1 |> time2 |> square
pipe(5, add1, time2, square)
```

```js
// Service = Low-level operation -> Low-level operation
Address -> AddressValidator => ValidationResult

// Use-case = Service -> Service
// ChangeProfileRequest -> UpdateProfileData => ChangeProfileResult

// Web-application = Use-case -> Use-case
// HttpRequest -> WebApplication => HttpResponse
```

One direction flow. Same for Flux pattern.

# Types

Type is a set of things.

# Types composition

_Algebraic_ composable type system. Use "AND" (record/product) and "OR" (choise/sum) to compose types.

```charp
// Fruit salad = Banana AND Apple AND Cherry
enum AppleVariety { Green, Yellow }
struct FruitSalad { BananaVariety Banana; AppleVariety Apple; CherryVariety Cherry; }
```

```ts
// Snack = Banana OR Apple OR Cherry
type Snack = BananaVariety  AppleVariety | CherryVariety;
```

One approach - have interfaces and implementations.
Second one:

```ts
type EmailAddress = string
type CardNumber = number
type CardType = Visa | Mastercard
type CCInfo = { CardNumber, CardType }
type PaymentMethod = { Cach, CC }
type PaymentAmount = number
type Cyrrency = USD | EUR
type Payment = { PaymentAmount Amount, Currency Currency, PaymentMethod Method }
```

----

```ts
foo = x = x + 10
bar = (x, y) => x * y
bar(foo(1), ?) // Can NOT be composed

// Curring!
barCurried = x => y => x * y
barCurried(foo(1)) // Partial application
```

input -> function => handler OR unhandled (null, error, exception, etc)
```ts
type OperationResult = Handled | Unhandled
foo = x => {
  result1 = handler1(x)
  if (result1 is Unhandled) return Unhandled;
  
  result2 = handler2(result1);
  if (result1 is Unhandled) return Unhandled;
  
  return result2
}

ifHandledDo = (f, result) = result is Handled ? f(result) : result
handler1 |> ifHandledDo handler2 |> ifHandledDo handler3
```

Chaining promises
```js
task = input => {
  startTask(input)
    .then(x => thenTask1(x)
      .then(y => thenTask2(y)
        .then(z => do(z))
        .catch()        
      )
      .catch()
    )
    .catch()
}

whenFinishedDo = (f task) => task.then(x => f(x))
task = input => startTask(input) |> whenFinishedDo(thenTask1) |> whenFinishedDo(thenTask2)
```

General solution for composing/chaining such stuff?
Before `- f =`. After `= f =`. Monad aka "Bind" adapter block aka Function transformer.

```cs
var bind nextFunction result = result is Unhandled ? nextFunction(result) : Handled(result)
```

# Kleisli composition

`-= + -= = -=`

```cs
// HttpHandler WebPart
class HttpContext { Request, Response, ... }
Async<Option<HttpContext>> HttpHandler(HttpContext)
```

# Summary
Reusable, testable, clear (one-direction), maintainable (explicit dependencies), extandable (add new part without touching other)

----

[0] fsharpforfunandprofit