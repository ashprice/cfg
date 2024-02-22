return {
  s("hi",
  { t("Hello, world!"), }
  ),
  s({trig="tt", descr="Expands 'tt' into '\texttt{}'"},
  fmta(
    [[
      \texttt{<>} <>
    ]],
    { i(1), i(0) },
    { delimiters = "<>" }
  )
  ),
  s({trig="sec", descr="Expands 'sec' into a section environment"},
  fmta(
    [[
      \section{<>}

      <>
    ]],
    { i(1), i(0) },
    { delimiters = "<>" }
  )
  ),
  s({trig="ssecs"},
  fmta(
  [[
    \subsection*{<>}

    <>
  ]],
  { i(1), i(0) },
  { delimiters = "<>" }
  )
  ),
  s({trig="cite"},
  fmta(
  [[
    \cite[<>]{<>} <>
  ]],
  { i(1), i(2), i(0) },
  { delimiters = "<>" }
  )
  ),
  s({trig="bq"},
  fmta(
  [[
    \blockquote[{\cite[<>]{<>}}]{<>}

    <>
  ]],
  { i(1), i(2), i(3), i(4) },
  { delimiters = "<>" }
  )
  ),
  s({trig="env"},
  fmta(
  [[
    \begin{<>}
    <>
    \end{<>}
  ]],
  {
    i(1),
    i(2),
    rep(1), -- this node repeats insert node i(1)
  }
  )
  ),
}
