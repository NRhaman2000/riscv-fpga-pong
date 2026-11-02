# PLL IP

This folder holds the Quartus ALTPLL that turns the DE10-Lite 50 MHz clock into the ~25.175 MHz VGA pixel clock. The project expects `ip/pll.qip` and `ip/pll.v` (the `.qsf` points to `ip/pll.qip`).

To regenerate it: in Quartus open **Tools > IP Catalog > ALTPLL**, save it as `ip/pll.v` (module name `pll`), set the input to 50 MHz, set output `c0` to 25.175 MHz, and turn off the optional `areset` and `locked` ports so the module only has `inclk0` and `c0`.
