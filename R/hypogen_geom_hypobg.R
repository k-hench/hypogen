#' Add linkage group annotation
#'
#' @param mapping     Set of aesthetic mappings created by aes()
#' @param data        The data to be displayed in this layer - usually hypogen::hypo_karyotype
#' @param stat        string, "identity"
#' @param position    Position adjustment "identity"
#' @param ...         Other arguments passed on to layer().
#' @param na.rm       If FALSE, the default, missing values are removed with a warning
#' @param show.legend logical. Should this layer be included in the legends?
#' @param inherit.aes logical
#'
#' @export
geom_hypobg <- function(mapping = NULL, data = NULL,
                           stat = "identity", position = "identity",
                           ...,
                           na.rm = FALSE,
                           show.legend = NA,
                           inherit.aes = TRUE) {
  layer(
    data = data,
    mapping = mapping,
    stat = stat,
    geom = GeomRectBG,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      na.rm = na.rm,
      ...
    )
  )
}

ggname <- function(prefix, grob) {
  grob$name <-  grid::grobName(grob, prefix)
  grob
}

GeomRectBG <- ggproto("GeomRectBG", Geom,
                        default_aes = aes(colour = NA, fill = "grey35", hypobg = NA,
                                          size = 0.5, linetype = 1, alpha = NA),

                        required_aes = c("xmin", "xmax", "ymin", "ymax"),

                        draw_panel = function(self, data, panel_params, coord) {
                          if (!coord$is_linear()) {
                            aesthetics <- setdiff(
                              names(data), c("x", "y", "xmin", "xmax", "ymin", "ymax")
                            )

                            polys <- plyr::alply(data, 1, function(row) {
                              poly <- rect_to_poly(row$xmin, row$xmax, row$ymin, row$ymax)
                              aes <- as.data.frame(row[aesthetics],
                                                   stringsAsFactors = FALSE)[rep(1,5), ]

                              GeomPolygon$draw_panel(cbind(poly, aes), panel_params, coord)
                            })

                            ggname("bar", do.call("grobTree", polys))
                          } else {
                            coords <- coord$transform(data, panel_params)
                            ggname("geom_rect",  grid::rectGrob(
                              coords$xmin, coords$ymax,
                              width = coords$xmax - coords$xmin,
                              height = coords$ymax - coords$ymin,
                              default.units = "native",
                              just = c("left", "top"),
                              gp =  grid::gpar(
                                col = alpha(coords$colour, coords$alpha),
                                fill = alpha(coords$hypobg, coords$alpha),
                                lwd = coords$size * .pt,
                                lty = coords$linetype,
                                lineend = "butt"
                              )
                            ))
                          }
                        },

                        draw_key = draw_key_polygon
)

rect_to_poly <- function(xmin, xmax, ymin, ymax) {
  data.frame(
    y = c(ymax, ymax, ymin, ymin, ymax),
    x = c(xmin, xmax, xmax, xmin, xmin)
  )
}

#' Manual linkage group color scale
#'
#' @param ...         parameters passed to ggplot2:::manual_scale()
#' @param values      string vector, color values
#' @param aesthetics  string, "hypobg"
#'
#' @export
scale_hypobg_manual <- function (..., values, aesthetics = "hypobg")
{
  manual_scale(aesthetics, values, ...)
}

#' Scale Linkage Group background
#'
#' @param ...        parameters passed to ggplot2::continuous_scale()
#' @param type       string, RColorBrewer palette type
#' @param palette    integer, RColorBrewer palette index
#' @param direction  numeric (1/ -1)
#' @param values     numeric vector, passed to scales::gradient_n_pal
#' @param space      colour space in which to calculate gradient, passed to scales::gradient_n_pal
#' @param na.value    Missing values will be replaced with this value.
#' @param guide       ggplot2::guide
#' @param aesthetics  string ("hypobg")
#'
#' @export
scale_hypobg_distiller <- function (..., type = "seq", palette = 1, direction = -1, values = NULL,
                                    space = "Lab", na.value = "grey50", guide = "colourbar",
                                    aesthetics = "hypobg")
{
  type <- match.arg(type, c("seq", "div", "qual"))
  if (type == "qual") {
    warning("Using a discrete colour palette in a continuous scale.\n  Consider using type = \"seq\" or type = \"div\" instead",
            call. = FALSE)
  }
  continuous_scale(aesthetics, "distiller",
                   scales::gradient_n_pal(scales::brewer_pal(type, palette, direction)(6), values, space),
                   na.value = na.value,
                   guide = guide, ...)
}

#' Clone of guide_colorbar for linkage group background
#'
#' @param title           clone, s. ggplot2::guide_colorbar()
#' @param title.position  clone, s. ggplot2::guide_colorbar()
#' @param title.theme     clone, s. ggplot2::guide_colorbar()
#' @param title.hjust     clone, s. ggplot2::guide_colorbar()
#' @param title.vjust     clone, s. ggplot2::guide_colorbar()
#' @param label           clone, s. ggplot2::guide_colorbar()
#' @param label.position  clone, s. ggplot2::guide_colorbar()
#' @param label.theme     clone, s. ggplot2::guide_colorbar()
#' @param label.hjust     clone, s. ggplot2::guide_colorbar()
#' @param label.vjust     clone, s. ggplot2::guide_colorbar()
#' @param barwidth        clone, s. ggplot2::guide_colorbar()
#' @param barheight       clone, s. ggplot2::guide_colorbar()
#' @param nbin            clone, s. ggplot2::guide_colorbar()
#' @param raster          clone, s. ggplot2::guide_colorbar()
#' @param frame.colour    clone, s. ggplot2::guide_colorbar()
#' @param frame.linewidth clone, s. ggplot2::guide_colorbar()
#' @param frame.linetype  clone, s. ggplot2::guide_colorbar()
#' @param ticks           clone, s. ggplot2::guide_colorbar()
#' @param ticks.colour    clone, s. ggplot2::guide_colorbar()
#' @param ticks.linewidth clone, s. ggplot2::guide_colorbar()
#' @param draw.ulim       clone, s. ggplot2::guide_colorbar()
#' @param draw.llim       clone, s. ggplot2::guide_colorbar()
#' @param direction       clone, s. ggplot2::guide_colorbar()
#' @param default.unit    clone, s. ggplot2::guide_colorbar()
#' @param reverse         clone, s. ggplot2::guide_colorbar()
#' @param order           clone, s. ggplot2::guide_colorbar()
#' @param available_aes   string, extended ggplot2::guide_colorbar() options by "hypobg"
#' @param ...             clone, s. ggplot2::guide_colorbar()
#'
#' @export
guide_colorbar_hypobg <- function (title = waiver(), title.position = NULL, title.theme = NULL,
                                   title.hjust = NULL, title.vjust = NULL, label = TRUE, label.position = NULL,
                                   label.theme = NULL, label.hjust = NULL, label.vjust = NULL,
                                   barwidth = NULL, barheight = NULL, nbin = 20, raster = TRUE,
                                   frame.colour = NULL, frame.linewidth = 0.5, frame.linetype = 1,
                                   ticks = TRUE, ticks.colour = "white", ticks.linewidth = 0.5,
                                   draw.ulim = TRUE, draw.llim = TRUE, direction = NULL, default.unit = "line",
                                   reverse = FALSE, order = 0, available_aes = c("colour", "color",
                                                                                 "fill", "hypobg"), ...)
{
  if (!is.null(barwidth) && !is.unit(barwidth))
    barwidth <- unit(barwidth, default.unit)
  if (!is.null(barheight) && !is.unit(barheight))
    barheight <- unit(barheight, default.unit)
  structure(list(title = title, title.position = title.position,
                 title.theme = title.theme, title.hjust = title.hjust,
                 title.vjust = title.vjust, label = label, label.position = label.position,
                 label.theme = label.theme, label.hjust = label.hjust,
                 label.vjust = label.vjust, barwidth = barwidth, barheight = barheight,
                 nbin = nbin, raster = raster, frame.colour = frame.colour,
                 frame.linewidth = frame.linewidth, frame.linetype = frame.linetype,
                 ticks = ticks, ticks.colour = ticks.colour, ticks.linewidth = ticks.linewidth,
                 draw.ulim = draw.ulim, draw.llim = draw.llim, direction = direction,
                 default.unit = default.unit, reverse = reverse, order = order,
                 available_aes = available_aes, ..., name = "colorbar"),
            class = c("guide", "colorbar"))
}

manual_scale <- function(aesthetic, values = NULL, ...) {
  # check for missing `values` parameter, in lieu of providing
  # a default to all the different scale_*_manual() functions
  if (rlang::is_missing(values)) {
    values <- NULL
  } else {
    force(values)
  }

  pal <- function(n) {
    if (n > length(values)) {
      stop("Insufficient values in manual scale. ", n, " needed but only ",
           length(values), " provided.", call. = FALSE)
    }
    values
  }
  discrete_scale(aesthetic, "manual", pal, ...)
}
