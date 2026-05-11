install: clean
	@ln -sv $(PWD)/snake.p8 $(HOME)/Library/Application\ Support/pico-8/carts/snake.p8

clean:
	@rm -v $(HOME)/Library/Application\ Support/pico-8/carts/snake.p8 2> /dev/null || true
