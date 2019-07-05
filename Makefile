.PHONY: tests clean

tests: sic
	@echo TST prepare
	@rm -f a.out
	@echo TST '"abc"'
	@cat tsts/a.txt | ./sic
	@diff a.out tsts/a.txt
	@echo TST '"abcdef"'
	@cat tsts/b.txt | ./sic
	@diff a.out tsts/b.txt
	@echo TST '"abc" (2)'
	@cat tsts/a.txt | ./sic
	@diff a.out tsts/a.txt
	@echo TST '"abd"'
	@cat tsts/c.txt | ./sic
	@diff a.out tsts/c.txt
	@echo TST not modified
	@ls -al tsts >ls-1.txt
	@cat tsts/a.txt | ./sic tst/a.out; true
	@ls -al tsts >ls-2.txt
	@diff ls-1.txt ls-2.txt
	@rm ls-1.txt ls-2.txt

sic: index.x
	@echo HX
	@hx

clean:
	@echo RM
	@rm -f sic a.out
