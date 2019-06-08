import vim

cIncludedId = vim.eval("hlID('cIncluded')")

def inside_include():
	synstack = vim.eval('synstack(line("."), col("."))')
	return len(synstack) > 0 and synstack[-1] == cIncludedId
