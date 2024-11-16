local get_visual = function(args, parent)
  if (#parent.snippet.env.LS_SELECT_RAW > 0) then
    return sn(nil, i(1, parent.snippet.env.LS_SELECT_RAW))
  else  -- If LS_SELECT_RAW is empty, return a blank insert node
    return sn(nil, i(1))
  end
end

local line_begin = require("luasnip.extras.expand_conditions").line_begin

function line_begin_or_non_letter(line_to_cursor, matched_trigger)
  local line_begin = line_to_cursor:sub(1, -(#matched_trigger + 1)):match("^%s*$")
  local non_letter = line_to_cursor:sub(-(#matched_trigger + 1), -(#matched_trigger + 1)):match("[^%a]")
  return line_begin or non_letter
end

local tex_utils = {}
tex_utils.in_mathzone = function()  -- math context detection
  return vim.fn['vimtex#syntax#in_mathzone']() == 1
end
tex_utils.in_text = function()
  return not tex_utils.in_mathzone()
end
tex_utils.in_comment = function()  -- comment detection
  return vim.fn['vimtex#syntax#in_comment']() == 1
end
tex_utils.in_env = function(name)  -- generic environment detection
    local is_inside = vim.fn['vimtex#env#is_inside'](name)
    return (is_inside[1] > 0 and is_inside[2] > 0)
end
-- A few concrete environments---adapt as needed
tex_utils.in_equation = function()  -- equation environment detection
    return tex_utils.in_env('equation')
end
tex_utils.in_itemize = function()  -- itemize environment detection
    return tex_utils.in_env('itemize')
end
tex_utils.in_tikz = function()  -- TikZ picture environment detection
    return tex_utils.in_env('tikzpicture')
end

local function column_count_from_string(descr)
	-- this won't work for all cases, but it's simple to improve
	-- (feel free to do so! :D )
	return #(descr:gsub("[^clm]", ""))
end

-- function for the dynamicNode.
local tab = function(args, snip)
	local cols = column_count_from_string(args[1][1])
	-- snip.rows will not be set by default, so handle that case.
	-- it's also the value set by the functions called from dynamic_node_external_update().
	if not snip.rows then
		snip.rows = 1
	end
	local nodes = {}
	-- keep track of which insert-index we're at.
	local ins_indx = 1
	for j = 1, snip.rows do
		-- use restoreNode to not lose content when updating.
		table.insert(nodes, r(ins_indx, tostring(j).."x1", i(1)))
		ins_indx = ins_indx+1
		for k = 2, cols do
			table.insert(nodes, t" & ")
			table.insert(nodes, r(ins_indx, tostring(j).."x"..tostring(k), i(1)))
			ins_indx = ins_indx+1
		end
		table.insert(nodes, t{"\\\\", ""})
	end
	-- fix last node.
	nodes[#nodes] = t""
	return sn(nil, nodes)
end

local rec_ls
rec_ls = function()
  return sn(nil, {
    c(1, {
      t({""}),
      sn(nil, {t({"", "\t\\item "}), i(1), d(2, rec_ls, {})}),
    }),
  });
end

local rec_c
rec_c = function()
  return sn(nil, {
    c(1, {
      t({""}),
      sn(nil, {t("["), i(1), t("]{"), i(2), t("}"), d(3, rec_c, {})}),
      sn(nil, {t("["), i(1), t("]["), i(2), t("]{"), i(3), t("}"), d(4, rec_c, {})}),
      sn(nil, {t("{"), i(1), t("}"), d(2, rec_c, {})}),
    }),
  });
end

return {
  s({trig="tt", regTrig=true, wordTrig=false, snippetType='autosnippet', descr="Expands 'tt' into '\texttt{}'"},
  fmta(
    [[
      <>\texttt{<>} <>
    ]],
    { f( function(_, snip) return snip.captures[1] end ), d(1, get_visual), i(0) }
  ), {condition=line_begin_or_non_letter}),
  s({trig="tii", regTrig=true, wordTrig=false, snippetType='autosnippet'},
  fmta(
    [[
      <>\textit{<>} <>
    ]],
    { f( function(_, snip) return snip.captures[1] end ), d(1, get_visual), i(0) }
  ), {condition=line_begin_or_non_letter}),
  s({trig="tbb", regTrig=true, wordTrig=false, snippetType='autosnippet'},
  fmta(
    [[
      <>\textbf{<>} <>
    ]],
    { f( function(_, snip) return snip.captures[1] end ), d(1, get_visual), i(0) }
  ), {condition=line_begin_or_non_letter}),
  s({trig="hp", snippetType = 'autosnippet'},
  fmta(
    [[
      \part{<>}

      <>
    ]],
    { i(1), i(0) }
  ), {condition = line_begin}),
  s({trig="hc", snippetType = 'autosnippet'},
  fmta(
    [[
      \chapter<>

      <>
    ]],
    { c(1, {sn(nil, {t("{"), i(1), t("}")}), sn(nil, {t("{"), i(1, "rep"), t("}\\label{chap:"), rep(1, "rep"), t("}")}), sn(nil, {t("{"), i(1, "diff"), t("}\\label{chap:"), i(2, "diff"), t("}")})}), i(0) }
  ), {condition = line_begin}),
  s({trig="h1", snippetType = 'autosnippet'},
  fmta(
  [[
    \section<>

    <>
  ]],
  { c(1, {sn(nil, {t("{"), i(1), t("}")}), sn(nil, {t("{"), i(1, "rep"), t("}\\label{sec:"), rep(1, "rep"), t("}")}), sn(nil, {t("{"), i(1, "diff"), t("}\\label{sec:"), i(2, "diff"), t("}")})}), i(0) }
  ), {condition = line_begin}),
  s({trig="h2", snippetType = 'autosnippet'},
  fmta(
    [[
      \subsection<>

      <>
    ]],
    { c(1, {sn(nil, {t("{"), i(1), t("}")}), sn(nil, {t("{"), i(1, "rep"), t("}\\label{sec:"), rep(1, "rep"), t("}")}), sn(nil, {t("{"), i(1, "diff"), t("}\\label{sec:"), i(2, "diff"), t("}")})}), i(0) }
  ), {condition = line_begin}),
  s({trig=",c", snippetType = 'autosnippet'},
  fmta(
    [[
      \cite<> <>
    ]],
    { c(1, {sn(nil, {t("["), i(1), t("]{"), i(2), t("}")}), sn(nil, {t("s("), i(1), t(")()"), c(2, {sn(nil, {t("["), i(1), t("]{"), i(2), t("}"), d(3, rec_c, {})}), sn(nil, {t("["), i(1), t("]["), i(2), t("]{"), i(3), t("}"), d(4, rec_c, {})})})})}), i(0)}
  )),
  s({trig=",p", snippetType = 'autosnippet'},
  fmta(
    [[
      \parencite<> <>
    ]],
    { c(1, {sn(nil, {t("["), i(1), t("]{"), i(2), t("}")}), sn(nil, {t("s("), i(1), t(")()"), c(2, {sn(nil, {t("["), i(1), t("]{"), i(2), t("}"), d(3, rec_c, {})}), sn(nil, {t("["), i(1), t("]["), i(2), t("]{"), i(3), t("}"), d(4, rec_c, {})})})})}), i(0)}
  )),
  s({trig=",f", snippetType = 'autosnippet'},
  fmta(
    [[
      \fullcite[<>]{<>}
      <>
    ]],
    { i(1), i(2), i(0) }
  ), {condition = line_begin}),
  s({trig=",n", snippetType = 'autosnippet'},
  fmta(
    [[
      \nocite{<>} <>
    ]],
    { i(1), i(0) }
  ), {condition = line_begin_or_non_letter}),
  s({trig="bq", snippetType = 'autosnippet'},
  fmta(
    [[
      \blockquote[{\cite[<>]{<>}}]{<>}

      <>
    ]],
    { i(1), i(2), i(3), i(0) }
  ), {condition = line_begin}),
  s({trig="env", snippetType = 'autosnippet'},
  fmta(
    [[
      \begin{<>}
      <>
      \end{<>}

      <>
    ]],
    { i(1), d(2, get_visual), rep(1), i(0) }
  ), {condition = line_begin}),
  s({trig="hr"},
  fmta(
    [[
      \href{<>}{<>}<>
    ]],
    { i(1, "url"), i(2, "display text"), i(0) }
  )),
  s({trig="([^%a])mm", wordTrig=false, regTrig=true, snippetType='autosnippet'},
  fmta(
    [[
      <>$<>$<>
    ]],
    { f( function(_, snip) return snip.captures[1] end ), d(1, get_visual), i(0) }
  )),
  s({trig="^mm", regTrig=true, wordTrig=false, snippetType='autosnippet'},
  fmta(
    [[
      $<>$<>
    ]],
    { i(1), i(0) }
  )),
  s({trig="([^%a])tee", regTrig=true, wordTrig=false, snippetType='autosnippet'},
  fmta(
    [[
      <>\\text{<>}<>
    ]],
    { f( function(_, snip) return snip.captures[1] end ), d(1, get_visual), i(0) }
  ), {condition=tex_utils.in_mathzone}),
  s({trig="([^%a])ff", wordTrig=false, regTrig=true, snippetType='autosnippet'},
  fmta(
    [[
      <>\frac{<>}{<>}<>
    ]],
    { f( function(_, snip) return snip.captures[1] end ), i(1), i(2), i(0) }
  )),
  s({trig="dd", snippetType='autosnippet'},
  fmta(
  "\\draw [<>] ",
  { i(1, "params") }
  ), {condition=tex_utils.in_tikz}),
  s({trig="nn", snippetType="autosnippet"},
  fmta(
    [[
      \begin{equation}
        <>
      \end{equation}

      <>
    ]],
    { i(1), i(0) }
  ), {condition=line_begin}),
  s({trig="itt", snippetType='autosnippet'},
  fmta(
    [[
      \begin{itemize}
        \item <>
      \end{itemize}
    ]],
    { i(0) }
  ), {condition=line_begin}),
  s({trig="enn", snippetType='autosnippet'},
  fmta(
    [[
      \begin{enumerate}
        \item <>
      \end{enumerate}
    ]],
    { i(0) }
  ), {condition=line_begin}),
  s({trig="fig"},
  fmta(
    [[
      \begin{figure}[htb!]
        \centering
        \includegraphics[width=<>\linewidth]{<>}
        \caption{<>}
        \label{fig:<>}
      \end{figure}

      <>
    ]],
    { i(1), i(2), i(3), i(4), i(0) }
  ), {condition=line_begin}),
  s({trig="ii", snippetType='autosnippet'},
  { t("\\item")}, {condition=line_begin}),
  s({trig=";;sel", snippetType='autosnippet', desc="Gives an otherlanguage environment - for longer prose."},
  fmta(
    [[
      \begin{otherlanguage}{<>}
      <>
      \end{otherlanguage}

      <>
    ]],
    { i(1), d(2, get_visual), i(0) }
  ), {condition=line_begin}),
  s({trig=";;jp", snippetType='autosnippet', descr="Gives a Japanese otherlanguage environment - for longer prose."},
  fmta(
    [[
      \begin{otherlanguage}{japanese}
      <>
      \end{otherlanguage}

      <>
    ]],
    { i(1), i(0) }
  ), {condition=line_begin}),
  s({trig=";sel", snippetType='autosnippet', descr="Gives a foreignlanguage environment - for shorter spans of text."},
  fmta(
    [[
      \foreignlanguage{<>}{<>} <>
    ]],
    { i(1), d(2, get_visual), i(0) }
  ), {condition=line_begin_or_non_letter}),
  s({trig=";jp", snippetType='autosnippet', descr="Gives a Japanese foreignlanguage environment - for shorter spans of text."},
  fmta(
    [[
      \foreignlanguage{japanese}{<>} <>
    ]],
    { d(1, get_visual), i(0) }
  ), {condition=line_begin_or_non_letter}),
  s({trig="fn", wordTrig="true", regTrig="false", descr="Footnotes."},
  fmta(
  [[
    \footnote{<>} <>
  ]],
  { d(1, get_visual), i{0} }
  )),
  s({trig="refs", wordTrig="true", snippetType="autosnippet"},
  fmta(
    [[
      {
      \microtypesetup[protrusion=false]
      \printbibliography[segment=\therefsegment,heading=subbibintoc]
      \microtypesetup[protrusion=true]
      }

      <>
    ]],
    { i(0) }
    ), {condition=line_begin}),
  s({ trig = "qw", name = "inline code", dscr = "inline code, ft escape" },
    fmta([[
    \mintinline{<>}<>
    ]],
    { i(1, "text"), c(2, { sn(nil, { t("{"), i(1), t("}") }), sn(nil, { t("|"), i(1), t("|") }) }) }
    )),
  s("tab",
  fmta([[
    \begin{tabular}{<>}
      <>
    \end{tabular}
    ]],
    {i(1, "c"), d(2, tab, {1}, {
	  user_args = {
		-- Pass the functions used to manually update the dynamicNode as user args.
		-- The n-th of these functions will be called by dynamic_node_external_update(n).
		-- These functions are pretty simple, there's probably some cool stuff one could do
		-- with `ui.input`
		function(snip) snip.rows = snip.rows + 1 end,
		-- don't drop below one.
		function(snip) snip.rows = math.max(snip.rows - 1, 1) end
	  }
  } )})),
}


