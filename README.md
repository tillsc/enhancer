# Enhancer - Move your functionality to your data.

What have been the greatest problems in your last project? I bet the answer will
contain "ActiveRecord", "Datamapper", /Mongo.+/, "Hibernate" or any other
data to object mapper technology. But why do we always have problems
with our persistence layers?

I think this is because of the tendency to hide the real persistency (whether
it's relational or not) and to expose a pure object oriented API only. Basically
this seems to be a good idea because of all kinds of logic we want to attach to
our data. But this is not what we are commonly doing. We are squeezing our data
into our (object-oriented) functionality instead.

Enhancer is a small proof of concept project, arose from many discussions about
data mappers of all kind. It's basic idea is to keep the "low level" persistence
APIs as they are and to provide mechanisms to "enhance" the data provided by those
APIs with your functionality.

## Basics
Normally "low level" persistence APIs return some kind of complex data in first
level objects like Arrays or Hashes. E.g. a document-oriented database could
return an Array of Hashes. Enhancer is intended to be included into the top
level object (the Array) and to enhance the underlaying objects recursively.

Let us choose an example:

    @david =  {
      :first_name => 'David', 
      :last_name => 'HH', 
      :address => {:street => 'Sesame Street', :house_number => 1}
    }

We could have some functionality to work with this data. E.g.

    module Person
      def name
        "#{first_name} #{last_name}"
      end
    end

and

    module Address
      def full_address
        "#{street} #{house_number}"
      end
    end

Enhancer allows us to include those modules into our Data object:

    @david.enhance!("Person")

`@david` (and only `@david`) now has the method `name`. 

But wait. How does enhancer know to include `Address` into the Hash in 
`@david[:address]`? This is done by so called 'matchers'. So our example above must be 
extended by the following code:

    module Person
      extend Enhancer
      match :address, "Address" # The second parameter is the module name
      ...
    end

If you enhance the Hash `@david` with the Module `Person` this matcher will enhance
the Value belonging to the key `:address` with the Module `Address`. 

## Matchers
In this basic version of _enhancer_, Matchers are implemented for Arrays and
Hashes. You can implement your own matchers to be able to enhance Classes not yet
supported by _enhancer_. Take a look into the corresponding tests and into the
_lib_ directory to see how to do it.

There are two ways how to define a match: In the Modules and inline.

The module style is done by using the `match` method as seen above. This should
be used to encode enhancements which must always be done because of a
continual structure of the data. So if a _Person_ always contains objects
to be enhanced with _Address_, you should encode the matching into _Person_
directly.

The alternative inline style is done by providing further parameters to the `enhance!` call:

    @david.enhance!("Person", :address => "Address")

You can specify matchings of any depth by suppling nested Arrays and Hashes as seen
in the following example:

    @david.enhance!("Person", :address => ["Address", {:country => "Country"}])

This would enhance `@david[:address][:country]` by the Module `Country`.

### Array Matchers
Enhacer also comes with the ability to enhance Arrays. There are some different ways to 
specify which elements of the array should be enhanced:

* `"*"` will Enhance every element of the array,
* `4` will enhance the element with the index 4,
* `[5, 2]` will enhance 2 elements starting with the element 5,
* `2..8` will enhance all elements starting from element 2 to element 8.

Except of the `"*"` matcher this is very close to the known accessors of the standard 
ruby `Array` class.   
Let's take a look how this could look like in praxis:

    @people = [@david, @till, @some_other_guy]
    
    # Enhance every entry:
    @people.enhance!("*" => "Person")

    # Enhance the second entry only:
    @people.enhance!(1 => "Person")

    # Enhance the last two elements:
    @people.enhance!([-2, 2] => "Person")

Array and Hash matchers are combinable:
    
    @people.enhance(0 => {:address => "Address"})

This would enhance `@people[0][:address]` by the module `Address`.