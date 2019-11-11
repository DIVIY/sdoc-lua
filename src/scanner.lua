local DOCTREE = { }

function scan(file)
	local elements = { }

	-- loads the file contents
	local contents; do
		local file = io.open(file,"r")
		contents = file:read("*a")
		file:close()
	end

	-- scans them to tokens
	local lines = contents:split({ '\n', '\r' })
	for i = 1, #lines do
		-- convert the lines to different types
		local trimmed = lines[i]:trim({ ' ', '\t' })


		if trimmed:sub(1,2) == "--" then
			local text = trimmed:removeLeading("-"):removeLeading("\t"):removeLeading(" ")
			elements[#elements + 1] = { t = "comment", v = text }
		elseif trimmed:sub(1,8) == "function" then
			local text = trimmed:sub(9,#trimmed):removeLeading(" "):removeLeading("\t")
			local parOpen = string.find(text,"%(")
			local parClose = string.find(text,"%)")
			functionName = text:sub(1,parOpen - 1)

			local args = text:sub(parOpen+1,parClose-1):split(",")
			-- removes any spaces around the parameters
			for _,a in pairs(args) do a = a:trim(" ") end
			-- removes empty args
			for i = #args,1,-1 do if #args[i] == 0 then table.remove(args,i) end end

			elements[#elements + 1] = { t = "function", v = functionName, u = text, args = args }
		else
			elements[#elements + 1] = { t = "blank", v = nil }
		end

	end

	-- does the compacting and removing of uninteresting stuff
	elements = compact(elements)

	-- creates the doctree args table
	local docdef = { }; do
		-- some standard stuff first
		docdef.file = file

		if elements[1].t == "comment" then
			-- if the first comment block is a comment, then we can
			-- apply that to the whole tree.

			docdef.description = elements[1].v
		end

		local functions = { }
		for _,el in pairs(elements) do
			if el.t == "function" then
				local description = el.innerComment or el.outerComment or nil

				functions[#functions + 1] = {
					name = el.v,
					usage = el.u,
					arguments = el.args,
					description = description,
					returns = { }
				}
			end
		end

		docdef.functions = functions
	end

	return DOCTREE.new(docdef)
end

function compact(elements)

	-- collapses the comments, and puts them in functions if applicable.
	for i = #elements, 2, -1 do
		if elements[i].t == "comment" and elements[i-1].t == "comment" then
			local comment = table.remove(elements,i)
			elements[i-1].v = elements[i-1].v .. comment.v
		elseif elements[i].t == "comment" and elements[i-1].t == "function" then
			local comment = table.remove(elements,i)
			elements[i-1].innerComment = comment.v
		elseif elements[i].t == "function" and elements[i-1].t == "comment" then
			local comment = table.remove(elements,i-1)
			elements[i-1].outerComment = elements[i-1].outerComment or ""
			elements[i-1].outerComment = comment.v .. elements[i-1].outerComment
		end
	end

	-- removes all the blanks
	for i = #elements, 1, -1 do
		if elements[i].t == "blank" then
			table.remove(elements,i)
		end
	end

	return elements
end


function DOCTREE.new(args)
	local doctree = args

    setmetatable(doctree,DOCTREE)
    DOCTREE.__index = DOCTREE

    return doctree
end

return scan