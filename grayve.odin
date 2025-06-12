package grayve

import clay "clay-odin"
import "core:fmt"

COLOR_TEXT :: clay.Color{0x22, 0x22, 0x22, 0xff}
COLOR_SURFACE :: clay.Color{0xc0, 0xc0, 0xc0, 0xff}
COLOR_BTN_HIGHLIGHT :: clay.Color{0xff, 0xff, 0xff, 0xff}
COLOR_BTN_FACE :: clay.Color{0xdf, 0xdf, 0xdf, 0xff}
COLOR_BTN_SHADOW :: clay.Color{0x80, 0x80, 0x80, 0xff}
COLOR_WIN_FRAME :: clay.Color{0x0a, 0x0a, 0x0a, 0xff}
COLOR_DIALOG_BLUE :: clay.Color{0x00, 0x00, 0x80, 0xff}
COLOR_DIALOG_LIGHT_BLUE :: clay.Color{0x10, 0x84, 0xd0, 0xff}
COLOR_DIALOG_GRAY :: clay.Color{0x80, 0x80, 0x80, 0xff}
COLOR_DIALOG_LIGHT_GRAY :: clay.Color{0xb5, 0xb5, 0xb5, 0xff}
COLOR_LINK_BLUE :: clay.Color{0x00, 0x00, 0xff, 0xff}
COLOR_TRANSPARENT :: clay.Color{0x00, 0x00, 0x00, 0x00}

// border colors
COLOR_BORDER_INNER_BRIGHT :: clay.Color{0xdf, 0xdf, 0xdf, 0xff}
COLOR_BORDER_INNER_DIM :: clay.Color{0x80, 0x80, 0x80, 0xff}
COLOR_BORDER_OUTER_BRIGHT :: clay.Color{0xff, 0xff, 0xff, 0xff}
COLOR_BORDER_OUTER_DIM :: clay.Color{0x0a, 0x0a, 0x0a, 0xff}

Border_Style :: enum {
    Raised,
    Sunken,
}

// This map is used to track button state between frames for debounce. This is required to
// enable the button borders to respond visually to being held without rapid firing events.
@(private)
button_state: map[clay.ElementId]bool

@(private, init)
init_button_state_map :: proc() {
    button_state = make(map[clay.ElementId]bool)
}

button :: proc(id: clay.ElementId, $label: string, mouse_down: bool, text_config: clay.TextElementConfig) -> (clicked: bool) {
    prev_down := button_state[id] or_else false

    if clay.UI()({
        id = id,
        layout = {
            sizing = {
                clay.SizingFit({ min = 75 }),
                clay.SizingFit({ min = 23 }),
            },
            padding = {
                left = 12,
                right = 12,
            },
            childAlignment = {
                .Center,
                .Center,
            }
        },
        backgroundColor = COLOR_SURFACE,
    }){
        current_down := clay.Hovered() && mouse_down
        clay.Text(label, clay.TextConfig(text_config))
        border(id, current_down ? .Sunken : .Raised)
        clicked = prev_down && !current_down && clay.Hovered()
        button_state[id] = current_down
    }

    return clicked
}

border :: proc(id: clay.ElementId, style: Border_Style) {
    if clay.UI()({
        id = clay.ID_LOCAL("inner_top_left_border"),
        layout = {
            sizing = {
                clay.SizingGrow({}),
                clay.SizingGrow({}),
            },
        },
        floating = {
            parentId = id.id,
            zIndex = 0,
            attachTo = .Parent,
            pointerCaptureMode = .Passthrough,
        },
        backgroundColor = COLOR_TRANSPARENT,
        border = {
            width = { 2, 0, 2, 0, 0 },
            color = style == .Raised ? COLOR_BORDER_INNER_BRIGHT : COLOR_BORDER_INNER_DIM,
        }
    }){}

    if clay.UI()({
        id = clay.ID_LOCAL("inner_bottom_right_border"),
        layout = {
            sizing = {
                clay.SizingGrow({}),
                clay.SizingGrow({}),
            },
        },
        floating = {
            parentId = id.id,
            zIndex = 0,
            attachTo = .Parent,
            pointerCaptureMode = .Passthrough,
        },
        backgroundColor = COLOR_TRANSPARENT,
        border = {
            width = { 0, 2, 0, 2, 0 },
            color = style == .Raised ? COLOR_BORDER_INNER_DIM : COLOR_BORDER_INNER_BRIGHT,
        }
    }){}

    if clay.UI()({
        id = clay.ID_LOCAL("outer_top_left_border"),
        layout = {
            sizing = {
                clay.SizingGrow({}),
                clay.SizingGrow({}),
            },
        },
        floating = {
            parentId = id.id,
            zIndex = 0,
            attachTo = .Parent,
            pointerCaptureMode = .Passthrough,
        },
        backgroundColor = COLOR_TRANSPARENT,
        border = {
            width = { 1, 0, 1, 0, 0 },
            color = style == .Raised ? COLOR_BORDER_OUTER_BRIGHT : COLOR_BORDER_OUTER_DIM,
        }
    }){}

    if clay.UI()({
        id = clay.ID_LOCAL("outer_bottom_right_border"),
        layout = {
            sizing = {
                clay.SizingGrow({}),
                clay.SizingGrow({}),
            },
        },
        floating = {
            parentId = id.id,
            zIndex = 0,
            attachTo = .Parent,
            pointerCaptureMode = .Passthrough,
        },
        backgroundColor = COLOR_TRANSPARENT,
        border = {
            width = { 0, 1, 0, 1, 0 },
            color = style == .Raised ? COLOR_BORDER_OUTER_DIM : COLOR_BORDER_OUTER_BRIGHT,
        }
    }){}
}

status_bar :: proc(id: string, items: []string, text_config: clay.TextElementConfig) {
    status_bar_id := clay.ID(id)
    text_config := text_config
    text_config.wrapMode = .None
    if clay.UI()({
        id = status_bar_id,
        layout = {
            sizing = {
                clay.SizingGrow({}),
                clay.SizingFit({ min = 23 }),
            },
            // padding = clay.PaddingAll(8),
            childAlignment = {
                .Left,
                .Center,
            },
            childGap = 1,
        },
        backgroundColor = COLOR_SURFACE,
        clip = {
            horizontal = true,
        }
    }){
        for item, i in items {
            item_id := clay.ID_LOCAL(fmt.tprintf("%s_child_%d", id, i))
            if clay.UI()({
                id = item_id,
                layout = {
                    sizing = {
                        clay.SizingGrow({}),
                        clay.SizingGrow({}),
                    },
                    padding = {
                        left = 4,
                        right = 4,
                    },
                    childAlignment = {
                        .Left,
                        .Center,
                    },
                },
                backgroundColor = COLOR_SURFACE,
            }){
                clay.TextDynamic(item, clay.TextConfig(text_config))

                if clay.UI()({
                    id = clay.ID_LOCAL("top_left_border"),
                    layout = {
                        sizing = {
                            clay.SizingGrow({}),
                            clay.SizingGrow({}),
                        },
                    },
                    floating = {
                        parentId = item_id.id,
                        zIndex = 0,
                        attachTo = .Parent,
                        pointerCaptureMode = .Passthrough,
                    },
                    backgroundColor = COLOR_TRANSPARENT,
                    border = {
                        width = { 1, 0, 1, 0, 0 },
                        color = COLOR_BORDER_INNER_DIM,
                    }
                }){}

                if clay.UI()({
                    id = clay.ID_LOCAL("bottom_right_border"),
                    layout = {
                        sizing = {
                            clay.SizingGrow({}),
                            clay.SizingGrow({}),
                        },
                    },
                    floating = {
                        parentId = item_id.id,
                        zIndex = 0,
                        attachTo = .Parent,
                        pointerCaptureMode = .Passthrough,
                    },
                    backgroundColor = COLOR_TRANSPARENT,
                    border = {
                        width = { 0, 1, 0, 1, 0 },
                        color = COLOR_BORDER_INNER_BRIGHT,
                    }
                }){}
            }
        }
    }
}
