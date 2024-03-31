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
  s({trig="h1", snippetType = 'autosnippet'},
  fmta(
    [[
      \section{<>}

      <>
    ]],
    { i(1), i(0) }
  ), {condition = line_begin}),
  s({trig="h2s", snippetType = 'autosnippet'},
  fmta(
  [[
    \subsection*{<>}

    <>
  ]],
  { i(1), i(0) }
  ), {condition = line_begin}),
  s({trig="cite"},
  fmta(
    [[
      \cite[<>]{<>} <>
    ]],
    { i(1), i(2), i(0) }
  )),
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
    { i(1), i(2), rep(1), i(0) }
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
}
