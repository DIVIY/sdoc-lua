-- a basic documentation generator for lua, that focuses
-- on markdown. using this so you can document code with
-- clear comments, and also use those comments inside the
-- git repo md files, so you don't need to update docs
-- in two different places.

-- needs to add so we can load with init.lua
package.path = '?/init.lua;' .. package.path

local scanner = require('src.scanner')
-- loads the string functions into the metatable
require('lib.stringtools-lua'):addToMetatable()

function test(a,s,longerName,v)

end

function main(args)
	-- the main entry point

	if args.file then
		local doctree = scanner(args.file)

		local markdown = require('src.markdown')
		local text = markdown(doctree)

		print(text)
	end

end

function processArgs()
	-- process the arguements
	return { file = "sdoc.lua" }
end

-- actually running the stuff
local args = processArgs()
main(args)