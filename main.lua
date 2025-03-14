local list_images = ya.sync(function(state, _)
	local files = cx.active.current.files
	local images = {}
	for _, f in ipairs(files) do
		if f.cha.is_dummy or f.cha.len == 0 then
			state[i] = false
			goto continue
		end
		if f:mime() ~= nil and f:mime():find("^image/") ~= nil then
			images[#images + 1] = tostring(f.url)
		end
		::continue::
	end
	return images
end)

--- TODO select several images

-- select single image
local select_image = ya.sync(function(state, filename)
	local target_index = 1
	for i, f in ipairs(cx.active.current.files) do
		if tostring(f.url) == filename then
			target_index = i
			break
		end
	end
	local delta = target_index - cx.active.current.cursor
	ya.manager_emit("arrow", { delta - 1 })
end)

return {
	entry = function()
		--- Get image files(through mime) from CWD, use them as sxiv arguments
		local imgs = list_images("")
		local out, err = Command("sxiv"):args({ "-t", "-o" }):args(imgs):output()
		if out.status.success == false or err ~= nil then
			ya.dbg(err, out.stdout)
			return
		end
		--- Split and get selected images from sxiv
		local selected = {}
		for i in string.gmatch(out.stdout, "([%S ]+)\n") do
			selected[#selected + 1] = i
		end
		if #selected == 0 then
			return
		end
		select_image(selected[1])
	end,
}
