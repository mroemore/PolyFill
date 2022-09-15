local NUM_OCTAVES = 10
local NUM_NOTES = 12
local DEFAULT_MARGIN = renoise.ViewBuilder.DEFAULT_CONTROL_MARGIN
local TEXT_ROW_WIDTH = 80

local note_strings = {
"C-", "C#", "D-", "D#", "E-", "F-", 
"F#", "G-", "G#", "A-", "A#", "B-"
}

renoise.tool():add_menu_entry {
    name = "Main Menu:Tools:PolyFill:1. Select and Fill...",
    invoke = function() pretty_hello_world() end 
}
local keybinding = {
    name = "Pattern Editor:PolyFill:polyfill",
    invoke = function() pretty_hello_world() end 
}
renoise.tool():add_keybinding(keybinding)

function select_all()
    renoise.song().selection_in_pattern = { start_line = 1, start_track = 1, end_line = 64, end_track = 1 } 
end

function init_selection()
    if(renoise.song().selection_in_pattern == nil)
    then
        renoise.song().selection_in_pattern = { start_line = 1, start_track = 1, end_line = 1, end_track = 1 } 
    end
end

function apply_fill()
    local start_line = renoise.song().selection_in_pattern.start_line
    local end_line = renoise.song().selection_in_pattern.end_line
    local lines = renoise.song().patterns[1].tracks[1]:lines_in_range(start_line, end_line)

    for i = 1,#(lines),1
    do
        lines[i].note_columns[1].note_string = "C-4"
        lines[i].note_columns[1].instrument_string = "00"
    end
end

function apply_euclidian_fill(factor)
    local start_line = renoise.song().selection_in_pattern.start_line
    local end_line = renoise.song().selection_in_pattern.end_line
    local lines = renoise.song().patterns[1].tracks[1]:lines_in_range(start_line, end_line)
    print("size: "..string.format(start_line - end_line).." start: "..string.format(start_line).." end: "..string.format(end_line))
    local pattern = generate_euclidean_pattern(factor, (end_line-(start_line)))
    for i = 1,#(lines),1
    do
        if pattern[i] == 1 then
            lines[i].note_columns[1].note_string = "C-4"
            lines[i].note_columns[1].instrument_string = "00"
        end
    end
end

function generate_euclidean_pattern(factor, size)
    local pattern = {}
    local remainder_size = 2
    local i = 0

    print("\nBEGIN\n")

    for i = 1, factor, 1
    do
        local new = {}
        table.insert(new, 1)
        table.insert(pattern,new)
    end
    for i = 1, size - factor, 1
    do
        local new = {}
        table.insert(new, 0)
        table.insert(pattern,{0})
    end

    --print(#(pattern))
    --print(pattern[1])
    --print(pattern[1][1])

    repeat
        for i = 1, #(pattern)/2, 1 do
            local inv_i = #(pattern)
            print(
                "p_length: "..string.format(#(pattern))..
                "i: "..string.format(i)..
                " rem: "..string.format(remainder_size)..
                " pat ["..string.format(i).."]: "..table.concat(pattern[i], "")..
                " + ["..string.format(inv_i).."]: "..table.concat(pattern[inv_i], "")
            )

            if pattern[i][1] == 1 and #(pattern[inv_i]) <= #(pattern[i])+1 then
                local to_merge = table.remove(pattern, (inv_i))

                --print(string.format(i) .. " val " .. table.concat(to_merge, ""))
                for j,v in ipairs(to_merge) do
                    table.insert(pattern[i], v)
                end
            end
        end
        remainder_size = remainder_size + 1 
        --print(#(pattern))
    until #(pattern) <= 1
    print("length:"..string.format(#(pattern[1])).."done:"..table.concat(pattern[1], ""))

    return pattern[1]
end

function get_euclid(factor, size)
    local pattern = {}

    for i = 1, factor, 1
    do
        local new = {}
        table.insert(new, 1)
        table.insert(pattern,new)
    end
    for i = 1, size - factor, 1
    do
        local new = {}
        table.insert(new, 0)
        table.insert(pattern,{0})
    end
    local r = better_euclid(pattern, 0)
    print(table.concat(r,""))
    return r
end

function better_euclid(pattern, remainder_size)
    if #(pattern) == 2 then
        for j,v in ipairs(pattern[2]) do
            table.insert(pattern[1], v)
        end
        return pattern[1]
    end
    local pulse_i = 1
    for i = #(pattern),1,-1 do
        --if i == pulse_i then break end
        if (pattern[i][1] == 0 and remainder_size == 0) or (#(pattern[i]) == remainder_size) then
            local to_merge = table.remove(pattern, i)
            print("apulse: "..string.format(pulse_i).." rem:"..string.format(remainder_size).." i:"..string.format(i).." rem:"..string.format(remainder_size) )
            for j,v in ipairs(to_merge) do
                table.insert(pattern[pulse_i], v)
            end
            pulse_i = pulse_i + 1
        end
        if pulse_i > #(pattern) then 
            pulse_i = 1 
        end
        if #(pattern[pulse_i]) <= remainder_size then
            pulse_i = 1
        end
    end
    return better_euclid(pattern, remainder_size+1)
end

function pretty_hello_world()
    local vb = renoise.ViewBuilder()
  
    local dialog_title = "Select and Fill"
    local dialog_buttons = {"OK"};

    local edit_pos = renoise.song().selected_line_index
    local max_lines = 64 -- renoise.InstrumentPhrase.MAX_NUMBER_OF_LINES
    -- local current_line_count = renoise.song().patterns[].tracks[].lines[]
    
    init_selection()
    local selection =  renoise.song().selection_in_pattern

    local tests = {

        table.concat(get_euclid(2,4), "") == "1010",
        table.concat(get_euclid(2,8), "") == "10001000",
        table.concat(get_euclid(3,8), "") == "10010100"
        --table.concat(get_euclid(5,13), "") == "1001010010100"
        --table.concat(generate_euclidean_pattern(8,16), "") == "1010101010101010",
        --table.concat(generate_euclidean_pattern(3,16), "") == "1000001000100000"
    }

    for i,v in ipairs(tests) do
        print("Test "..string.format(i).." result: ".. tostring(v))
    end

    local slider_row = vb:row {
        vb:text {
          width = TEXT_ROW_WIDTH,
          text = "vb:slider"
        },
        vb:slider {
          min = 1.0,
          max = 100,
          value = 20.0,
          notifier = function(value)
            show_status(("slider value changed to '%.1f'"):
              format(value))
          end
        }
      }
    
    -- start with a 'column' to stack other views vertically:
    local dialog_content = vb:column {
      -- set a border of DEFAULT_MARGIN around our main content
      margin = DEFAULT_MARGIN,
  
      -- and create another column to align our text in a different background
      vb:column {
        style = "group",
        margin = DEFAULT_MARGIN,
  
        vb:text {
          text = string.format("selection start: %s\n", selection.start_line)..
           string.format("selection end: %s", selection.end_line)
        },
      },
      vb:button {
        -- buttons can also have custom text/back colors
        text = "Select",
        width = 30,
        color = {0x22, 0xaa, 0xff},
        -- and we also can handle presses, releases separately
        pressed = function()
            select_all()
            apply_euclidian_fill(4)
        end,
        released = function()
          
        end,
      }
    }
  
    renoise.app():show_custom_prompt(
      dialog_title, dialog_content, dialog_buttons)
  
    -- lets go on and start to use some real controls (buttons & stuff) now...
  end