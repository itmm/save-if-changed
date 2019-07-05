# Save if Changed
* A small tool that saves the standard input to a file
* But only if it will change the content of this file
* This allows to change the modification date only if a modification
  actually happened
* And can improve build performance

## Main structure

```
@Def(| c++ -x c++ -Wall -o sic -)
	@put(needed by main)
	int main(
		int argc, const char *argv[]
	) {
		@put(main);
	}
@End(| c++ -x c++ -Wall -o sic -)
```
* Directly pipe the generated file to the C++ compiler
* The file consists of global elements

```
@def(needed by main)
	#include @s(<string>)
@end(needed by main)
```
* Needs declaration of `std::string`

```
@def(main)
	std::string path { "a.out" };
@end(main)
```
* Name of the output file can be changed with command line argument
* If not specified, a default value will be used

```
@add(main)
	@put(parse arguments);
@end(main)
```
* Arguments will be parsed later
* The business logic is coming first

```
@add(main)
	@put(algorithm);
@end(main)
```
* Perform algorithm after command line arguments are parsed

```
@add(needed by main)
	@put(needed by algorithm)
@end(needed by main)
```

## The Algorithm

```
@def(algorithm)
	int i, r;
@end(algorithm)
```
* `i` is the character read from `std::cin`
* `r` is the reference read from the file

```
@add(algorithm)
	long p = 0;
@end(algorithm)
```
* `p` is the current position in a file

```
@def(needed by algorithm)
	#include @s(<fstream>)
@end(needed by algorithm)
```
* Needs file stream

```
@add(algorithm)
	{
		std::ifstream @v(in) {
			path.c_str(),
			std::@t(ios_base)::@n(binary)
		};
		@put(read);
	}
@end(algorithm)
```
* Open file for reading and match with input

```
@add(needed by algorithm)
	#include @s(<iostream>)
@end(needed by algorithm)
```
* Needs input stream

```
@def(read)
	for (;;) {
		i = std::cin.get();
		r = @v(in).get();
		if (i != r || i == EOF) {
			break;
		}
		++p;
	}
@end(read)
```
* Continue until chars do not match
* Or the end is reached by one stream

```
@add(algorithm)
	if (i == EOF && r == EOF) {
		return @n(EXIT_FAILURE);
	}
@end(algorithm)
```
* If both files are done then the file do not need to change

```
@add(algorithm)
	{
		std::fstream out {
			path.c_str(),
			p ?
				std::@t(ios_base)::@n(binary) |
					std::@t(ios_base)::@n(in) |
					std::@t(ios_base)::@n(out)
			:
				std::@t(ios_base)::@n(binary) |
					std::@t(ios_base)::@n(out)
		};
		@put(write);
	}
@end(algorithm)
```
* Open output and write changed part
* File will not be created when `std::@t(ios_base)::@n(in)` is specified
* So it will be specified only if there is some data to sweep over
* Otherwise it will be replaced with zeros

```
@def(write)
	out.seekp(p);
@end(write)
```
* Seek to the position where change happens

```
@add(write)
	while (i != EOF) {
		out.put(i);
		i = std::cin.get();
		++p;
	}
@end(write)
```
* Write everything that is coming from `std::cin`

```
@add(needed by algorithm)
	#include @s(<unistd.h>)
	#include @s(<sys/types.h>)
@end(needed by algorithm)
```
* Includes for `truncate`

```
@add(algorithm)
	truncate(path.c_str(), p);
@end(algorithm)
```
* Truncate file to new length

```
@add(algorithm)
	return @n(EXIT_SUCCESS);
@end(algorithm)
```
* Return success

## Parse arguments

```
@def(parse arguments)
	bool parse_opts { true };
	for (int i = 1; i < argc; ++i) {
		std::string arg { argv[i] };
		if (parse_opts && arg[0] == '-') {
			@put(parse option)
		} else {
			path = arg;
		}
	}
@end(parse arguments)
```

```
@def(parse option)
	if (arg == "--") {
		parse_opts = false;
		continue;
	}
	if (arg != "-?" && arg != "--help") {
		std::cerr << "unknown option " <<
			arg << "\n";
	}
	@put(write description)
@end(parse option)
```

```
@def(write description)
	std::cout << "usage: " << argv[0] <<
		" [-?|--help|--] file_name\n";
	return @n(EXIT_FAILURE);
@end(write description)
```

