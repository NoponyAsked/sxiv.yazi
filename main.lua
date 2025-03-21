local list_images = ya.sync(function(state, _)
	local files = cx.active.current.files
	local images = {}
	for i, f in ipairs(files) do
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


-- get a position of hovered image amongst other images to pass the value to sxiv with '-n' flag
-- TO refactor dat son of a batch - somehow merge with list_images
local get_hovered = ya.sync(function(state, _)
	local f = cx.active.current.hovered

	-- TODO alternatively select the closest image
	if f:mime() == nil or f:mime():find("^image/") == nil then
		return 0
	end

	local files = cx.active.current.files
	local images = {}
	for _, ff in ipairs(files) do
		if ff:mime() ~= nil and ff:mime():find("^image/") ~= nil then
			images[#images + 1] = ff
		end
	end

	for i, ff in ipairs(images) do
		if ff.name == f.name then
			return i
		end
	end
	return 0
end)

-- TODO load all images into sxiv(currently it's based on mime and pretty slow, so only part of images are being used in sxiv)

return {
	entry = function()
		--- Get image files(through mime) from CWD, use them as sxiv arguments
		local imgs = list_images("")
		local args = { "-t", "-o" }
		local hovered = get_hovered()
		if hovered > 0 then
			args[#args + 1] = "-n " .. hovered
		end

		local out, err = Command("sxiv"):args(args):args(imgs):output()
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
