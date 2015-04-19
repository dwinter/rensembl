# CONTRIBUTING 

## Please contribute!
We love collaboration

## Bugs?

* Submit an issue on the Issues page [here](https://github.com/dwinter/rensembl/issues)

## Code/Documentation contributions

`rensembl` is still in an early stage of development, so there it lots to do. If
you want to jump in check out the current milestones and associated goals on
the issues page [here](https://github.com/dwinter/rensembl/issues)

###How we are developing `rensembl`

The function `map_species_builds`, [which hits this endpoint](http://rest.ensembl.org/documentation/info/assembly_map),
demonstrates the approach we are using to create these functions:

```r
map_species_builds <- function(species, region, asm_one, asm_two, 
                               coord_system="chromosome", format='json'){
    header = ensembl_header(format, c("json", "xml"))
    end <- paste("map", species, asm_one, region, asm_two, sep="/")
    print(end)
    q <- list(coord_system=coord_system)
    req <- ensembl_GET(end, header=header, body=q)
    httr::content(req)
}
```

* Name the function to more or less match the enpoint name, while describing
  what the function does
* Match the function arguments to the REST documentation, including default
  values (set those args that only make sense when others are set to NULL)
* Make use of functios in `base.r` to create headers, querys, bodys for requests
* Use ensembl_GET/ensembl_POST to make the request (as you'll see in `base` this
  performs checks too)
* Use `httr::content()` to return an R object (in the future there may be
  package-specific parsers for functions)

In some cases there are number of similar endpoints, with slightly different
arguments, data types or HTTP verbs. In cases were all endpoitns share a large
number of arguments, we've been writing a single funcion with enough arguments
to make each endpoitn identiable. For instance, the `variation_id` function will
use `POST` when it gets > 1 if, and `GET` when it get only 1

If there is any doubt in how to split up / lump a set of endpoints start and
issue to disuss it.

###Perferred way to contribute code

* Fork this repo to your Github account
* Clone your version on your account down to your machine from your account, e.g,. `git clone https://github.com/<yourgithubusername>/rensembl.git`
* Make sure to track progress upstream (i.e., on our version of `rensembl` at `dwinter/rensembl`) by doing `git remote add upstream https://github.com/dwinter/resembl`. Before making changes make sure to pull changes in from upstream by doing either `git fetch upstream` then merge later or `git pull upstream` to fetch and merge in one step
* Make your changes (bonus points for making changes on a new branch)
* Push up to your account
* Submit a pull request to home base at `dwinter/rensembl`

### Questions? Get in touch: [david.winter@gmail.com](mailto:david.winter@gmail.com)

### Thanks for contibuting!
