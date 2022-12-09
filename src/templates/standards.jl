#=
TODO: implement a template system
- from string and files
- implement an standard, per function, and custom key => substitution system
- possible syntax {{OBA: DATE}}
- Maybe add parameters to the tags
- Check/Implement compat with Obsidian templates
=#

const DATE_TEMPLATE_KEY = "{{OBA: DATE}}"

_templates_replace_date(template) = 
    replace(template, DATE_TEMPLATE_KEY => Dates.format(now(), "yyyy:mm:dd-HH:MM:SS"))


function _templates_replace_standards(template)
    template = _templates_replace_date(template)
end