function process(doctree)

	local string = ""

	string = string .. "# " ..doctree.file .. '\n\n' 
	string = string .. doctree.description .. '\n\n'

	if #doctree.functions > 0 then
		string = string .. "## functions" .. '\n\n'

		for _,v in pairs(doctree.functions) do
			string = string .. processFunction(v) .. '\n'
		end
	end

	return string

end

function processFunction(func)
	local text = ""

	text = text .. "### `" .. func.usage .. "`" .. '\n'
	if func.description then text = text .. func.description .. '\n' end
	text = text .. '\n'

	if #func.arguments > 0 then
		text = text .. "***Inputs***" ..'\n'

		for _,arg in pairs(func.arguments) do
			text = text .. "- **`" .. arg .. "`**" ..'\n'
		end

	end

	if #func.returns > 0 then
		text = text .. "***Outputs***" ..'\n'

		for _,arg in pairs(func.arguments) do
			text = text .. "- **`" .. arg .. "`**" ..'\n'
		end

	end

	return text
end

return process