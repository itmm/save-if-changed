
	
	#include <string>

	
	#include <fstream>

	#include <iostream>

	#include <unistd.h>
	#include <sys/types.h>


	int main(
		int argc, const char *argv[]
	) {
		
	std::string path { "a.out" };

	
	bool parse_opts { true };
	for (int i = 1; i < argc; ++i) {
		std::string arg { argv[i] };
		if (parse_opts && arg[0] == '-') {
			
	if (arg == "--") {
		parse_opts = false;
		continue;
	}
	if (arg != "-?" && arg != "--help") {
		std::cerr << "unknown option " <<
			arg << "\n";
	}
	
	std::cout << "usage: " << argv[0] <<
		" [-?|--help|--] file_name\n";
	return EXIT_FAILURE;


		} else {
			path = arg;
		}
	}
;

	
	int i, r;

	long p = 0;

	{
		std::ifstream in {
			path.c_str(),
			std::ios_base::binary
		};
		
	for (;;) {
		i = std::cin.get();
		r = in.get();
		if (i != r || i == EOF) {
			break;
		}
		++p;
	}
;
	}

	if (i == EOF && r == EOF) {
		return EXIT_FAILURE;
	}

	{
		std::fstream out {
			path.c_str(),
			p ?
				std::ios_base::binary |
					std::ios_base::in |
					std::ios_base::out
			:
				std::ios_base::binary |
					std::ios_base::out
		};
		
	out.seekp(p);

	while (i != EOF) {
		out.put(i);
		i = std::cin.get();
		++p;
	}
;
	}

	truncate(path.c_str(), p);

	return EXIT_SUCCESS;
;
;
	}
