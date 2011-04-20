# Enhancer - Move your functionality to your data.

What where the greatest problems in your last project? I bet the answer will
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
    @people = [
      {:first_name => 'David', :last_name => 'HH', :address => {:street => 'Sesame Street 1'}},
      {:first_name => 'Till', :last_name => 'SC'},
    ]

We could have some functionality to work with this data. E.g.
    module Person
      def name
        "#{first_name} #{last_name}"
      end
    end
and
    module People
      def names
        map do |person|
          person.name
        end
      end
    end

Enhancer allows us to include those modules into our Data object:
    @people.enhance!(People)
`@people` now has the method `names`. But wait. How does enhancer know to include
`Person`into the Hashes contained in `@people`? This is done by so called
'matchers'. So our example above must be extended by the following code:
    module People
      extend Enhancer
      match "*", "Person" # The second parameter is the module name
      ...
    end

## Matchers
In this basic version of _enhancer_, Matchers are implemented for Arrays and
Hashes. You can implement your own matchers to be able to enhace Classes not yet
supported by _enhancer_. Take a look into the corresponding tests and into the
_lib_ directory to see how to do it.

There are two ways how to define a match: Inline and in the Mixins themselfes.

The inline style is done by providing further parameters to the `enhance!` call:
    @people.enhance!("People", "*" => "Person")
This would enhance the array with the module _People_ and the array elements
with the _Person_ module.

The mixin style is done by using the `match` method as seen above. This should
be used to encode enhancements which should always be done because of a
continual structure of the data. So if the People Array always contains Objects
to be enhanced with Person, wou should encode the matching into People.
