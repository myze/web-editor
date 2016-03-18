WEBPACK_BIN = node ./node_modules/webpack/bin/webpack.js
ENTRY = src/App.coffee
OUTPUT = editor.js

b:
	@$(WEBPACK_BIN) $(ENTRY) $(OUTPUT) --optimize-minimize

w:
	@$(WEBPACK_BIN) $(ENTRY) $(OUTPUT) --watch