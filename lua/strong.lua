function Block(el)
    if el.t == "Para" or el.t == "Plain" then
        for k, _ in ipairs(el.content) do

            if el.content[k].t == "Str" and el.content[k].text == "Leftwich," then

                local _, e = el.content[k].text:find("Leftwich")
                local rest = el.content[k].text:sub(e + 1) -- empty if e+1>length
                el.content[k] = pandoc.Strong {pandoc.Str("Leftwich,")}
 

            end

        end
    end
    return el
end
