(function() {
  var Aggregation, Assign, Association, Attribute, Attributes, BRACES, Base, Brace, COMPASS_PTS, Comment, Composition, DELIMITERS, Delimiter, Diagram, Diagrams, E, Edge, Electric, Element, Ellipsis, Graph, Group, Hexagon, House, Id, Inheritance, KEYWORDS, Keyword, L, Link, LinkStyle, LinkStyles, Lozenge, Marker, Markers, Mouse, Node, Note, Number, OPERATORS, Octogon, Operator, PANIC_THRESHOLD, Parallelogram, ParserError, Pentagon, Polygon, QuotedId, RE_ALPHA, RE_ALPHADIGIT, RE_COMMENT, RE_DIGIT, RE_SPACE, Rect, Septagon, Star, Statement, SubGraph, Svg, Token, Transistor, Trapezium, Triangle, anchor_link_drag, angle_to_cardinal, atan2, attach_self, capitalize, cardinal, cardinal_to_direction, clip, commands, copy, cut, dist, dot, dot_lex, dot_tokenize, edit, edit_it, enter_link, enter_marker, enter_node, extern_drag, floating, generate_url, history_pop, init_commands, last_command, link_drag, list_diagrams, list_local, list_new, load, marker_to_dot, merge, merge_copy, mod2pi, mouse_link, mouse_node, mouse_xy, move_drag, next, node_add, node_style, nsweo_resize_drag, o_copy, order, paste, pi, remove, rotate, save, svg_selection_drag, text_style, tick_link, tick_node, timestamp, to_deg, to_rad, to_svg_angle, update_anchors, update_handles, update_link, update_marker, update_node, wrap, write_text, zoom,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  pi = Math.PI;

  to_deg = function(a) {
    return 180 * a / pi;
  };

  to_rad = function(a) {
    return pi * a / 180;
  };

  dist = function(o, t) {
    return Math.sqrt(Math.pow(t.x - o.x, 2) + Math.pow(t.y - o.y, 2));
  };

  rotate = function(pos, a) {
    return {
      x: pos.x * Math.cos(a) - pos.y * Math.sin(a),
      y: pos.x * Math.sin(a) + pos.y * Math.cos(a)
    };
  };

  mod2pi = function(a) {
    return ((a % (2 * pi)) + 2 * pi) % (2 * pi);
  };

  atan2 = function(y, x) {
    return mod2pi(Math.atan2(y, x));
  };

  to_svg_angle = function(a) {
    return to_deg(mod2pi(a));
  };

  cardinal = {
    N: 3 * pi / 2,
    S: pi / 2,
    W: pi,
    E: 0
  };

  angle_to_cardinal = function(a) {
    if ((pi / 4 < a && a <= 3 * pi / 4)) {
      return 'S';
    }
    if ((3 * pi / 4 < a && a <= 5 * pi / 4)) {
      return 'W';
    }
    if ((5 * pi / 4 < a && a <= 7 * pi / 4)) {
      return 'N';
    }
    return 'E';
  };

  cardinal_to_direction = function(c) {
    switch (c) {
      case 'N':
        return {
          x: 0,
          y: -1
        };
      case 'S':
        return {
          x: 0,
          y: 1
        };
      case 'W':
        return {
          x: -1,
          y: 0
        };
      case 'E':
        return {
          x: 1,
          y: 0
        };
      case 'SE':
        return {
          x: 1,
          y: 1
        };
      case 'SW':
        return {
          x: -1,
          y: 1
        };
      case 'NW':
        return {
          x: -1,
          y: -1
        };
      case 'NE':
        return {
          x: 1,
          y: -1
        };
    }
  };

  timestamp = function() {
    return new Date().getTime() * 1000 + Math.round(Math.random() * 1000);
  };

  capitalize = function(s) {
    return s.charAt(0).toUpperCase() + s.substr(1).toLowerCase();
  };

  next = function(o, k) {
    var keys, next_key;
    keys = Object.keys(o);
    next_key = keys[(keys.indexOf(k) + 1) % keys.length];
    if (next_key.indexOf('_') === 0) {
      return next(o, next_key);
    }
    return next_key;
  };

  merge = function(o1, o2) {
    var attr;
    for (attr in o2) {
      o1[attr] = o2[attr];
    }
    return o1;
  };

  o_copy = function(o) {
    var attr, c;
    c = {};
    for (attr in o) {
      c[attr] = o[attr];
    }
    return c;
  };

  merge_copy = function(o1, o2) {
    var attr, o3;
    o3 = {};
    for (attr in o1) {
      o3[attr] = o1[attr];
    }
    for (attr in o2) {
      o3[attr] = o2[attr];
    }
    return o3;
  };

  node_style = function(node) {
    var attrs, fillcolor, style, styles, _ref;
    if (!node.attrs) {
      return void 0;
    }
    styles = [];
    attrs = node.attrs;
    style = ((_ref = attrs.style) != null ? _ref.split(',') : void 0) || [];
    if (__indexOf.call(style, 'invisible') >= 0) {
      styles.push('display: none');
    }
    if (__indexOf.call(style, 'dashed') >= 0) {
      styles.push('stroke-dasharray: 10, 5');
    }
    if (__indexOf.call(style, 'dotted') >= 0) {
      styles.push('stroke-dasharray: 2, 6');
    }
    if (__indexOf.call(style, 'bold') >= 0) {
      styles.push('stroke-width: 2.5');
    }
    if (__indexOf.call(style, 'filled') >= 0) {
      fillcolor = attrs.fillcolor || attrs.color;
    } else {
      fillcolor = attrs.fillcolor;
    }
    if (fillcolor) {
      styles.push("fill: " + fillcolor + ";");
    }
    if (attrs.color != null) {
      styles.push("stroke: " + attrs.color + ";");
    }
    return styles.join('; ') || void 0;
  };

  text_style = function() {
    return 1;
  };

  attach_self = function(list, self) {
    var l, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = list.length; _i < _len; _i++) {
      l = list[_i];
      _results.push({
        key: l,
        self: self
      });
    }
    return _results;
  };

  d3.selection.prototype.dblTap = function(callback) {
    var last;
    last = 0;
    return this.each(function() {
      return d3.select(this).on("touchstart", function(e) {
        var rv;
        if ((d3.event.timeStamp - last) < 500) {
          rv = callback(e);
          d3.event.preventDefault();
          return rv;
        }
        return last = d3.event.timeStamp;
      });
    });
  };

  Base = (function() {
    function Base() {
      this.cls = this.constructor;
    }

    Base.prototype["super"] = function(fun, cls, args) {
      if (cls == null) {
        cls = null;
      }
      if (args == null) {
        args = [];
      }
      return (cls || this.cls).__super__[fun].apply(this, args);
    };

    return Base;

  })();

  LinkStyles = {};

  LinkStyle = (function(_super) {
    __extends(LinkStyle, _super);

    function LinkStyle() {
      return LinkStyle.__super__.constructor.apply(this, arguments);
    }

    LinkStyle.prototype.get = function(source, target, a1, a2, o1, o2) {
      return "M " + a1.x + " " + a1.y + " L " + a2.x + " " + a2.y;
    };

    return LinkStyle;

  })(Base);

  LinkStyles.Diagonal = (function(_super) {
    __extends(Diagonal, _super);

    function Diagonal() {
      return Diagonal.__super__.constructor.apply(this, arguments);
    }

    return Diagonal;

  })(LinkStyle);

  LinkStyles.Rectangular = (function(_super) {
    __extends(Rectangular, _super);

    function Rectangular() {
      return Rectangular.__super__.constructor.apply(this, arguments);
    }

    Rectangular.prototype.get = function(source, target, a1, a2, o1, o2) {
      var horizontal_1, horizontal_2, mid, path;
      horizontal_1 = Math.abs(o1 % pi) < pi / 4;
      horizontal_2 = Math.abs(o2 % pi) < pi / 4;
      path = "M " + a1.x + " " + a1.y + " L";
      if (!horizontal_1 && horizontal_2) {
        path = "" + path + " " + a1.x + " " + a2.y;
      } else if (horizontal_1 && !horizontal_2) {
        path = "" + path + " " + a2.x + " " + a1.y;
      } else if (horizontal_1 && horizontal_2) {
        mid = a1.x + .5 * (a2.x - a1.x);
        path = "" + path + " " + mid + " " + a1.y + " L " + mid + " " + a2.y;
      } else if (!horizontal_1 && !horizontal_2) {
        mid = a1.y + .5 * (a2.y - a1.y);
        path = "" + path + " " + a1.x + " " + mid + " L " + a2.x + " " + mid;
      }
      return "" + path + " L " + a2.x + " " + a2.y;
    };

    return Rectangular;

  })(LinkStyle);

  LinkStyles.Arc = (function(_super) {
    __extends(Arc, _super);

    function Arc() {
      return Arc.__super__.constructor.apply(this, arguments);
    }

    Arc.prototype.get = function(source, target, a1, a2, o1, o2) {
      var horizontal_1, horizontal_2, path, rx, ry;
      horizontal_1 = Math.abs(o1 % pi) < pi / 4;
      horizontal_2 = Math.abs(o2 % pi) < pi / 4;
      rx = Math.abs(a1.x - a2.x);
      ry = Math.abs(a1.y - a2.y);
      return path = "M " + a1.x + " " + a1.y + " A " + rx + " " + ry + " 0 0 1 " + a2.x + " " + a2.y;
    };

    return Arc;

  })(LinkStyle);

  LinkStyles.Demicurve = (function(_super) {
    __extends(Demicurve, _super);

    function Demicurve() {
      return Demicurve.__super__.constructor.apply(this, arguments);
    }

    Demicurve.prototype.get = function(source, target, a1, a2, o1, o2) {
      var horizontal_1, horizontal_2, m, path;
      horizontal_1 = Math.abs(o1 % pi) < pi / 4;
      horizontal_2 = Math.abs(o2 % pi) < pi / 4;
      path = "M " + a1.x + " " + a1.y + " C";
      m = {
        x: .5 * (a1.x + a2.x),
        y: .5 * (a1.y + a2.y)
      };
      if (horizontal_1) {
        path = "" + path + " " + m.x + " " + a1.y;
      } else {
        path = "" + path + " " + a1.x + " " + m.y;
      }
      if (horizontal_2) {
        path = "" + path + " " + m.x + " " + a2.y;
      } else {
        path = "" + path + " " + a2.x + " " + m.y;
      }
      return "" + path + " " + a2.x + " " + a2.y;
    };

    return Demicurve;

  })(LinkStyle);

  LinkStyles.Curve = (function(_super) {
    __extends(Curve, _super);

    function Curve() {
      return Curve.__super__.constructor.apply(this, arguments);
    }

    Curve.prototype.get = function(source, target, a1, a2, o1, o2) {
      var d, dx, dy, path;
      path = "M " + a1.x + " " + a1.y + " C";
      d = dist(a1, a2, o1, o2) / 2;
      if (source === target) {
        d *= 4;
        if ((o1 + o2) % pi === 0) {
          o1 -= pi / 4;
          o2 += pi / 4;
        }
      }
      dx = Math.cos(o1) * d;
      dy = Math.sin(o1) * d;
      path = "" + path + " " + (a1.x + dx) + " " + (a1.y + dy);
      dx = Math.cos(o2) * d;
      dy = Math.sin(o2) * d;
      path = "" + path + " " + (a2.x + dx) + " " + (a2.y + dy);
      return "" + path + " " + a2.x + " " + a2.y;
    };

    return Curve;

  })(LinkStyle);

  LinkStyles.Rationalcurve = (function(_super) {
    __extends(Rationalcurve, _super);

    function Rationalcurve() {
      return Rationalcurve.__super__.constructor.apply(this, arguments);
    }

    Rationalcurve.prototype.get = function(source, target, a1, a2, o1, o2) {
      var dx, dy, path;
      path = "M " + a1.x + " " + a1.y + " C";
      if (source === target) {
        if ((o1 + o2) % pi === 0) {
          o1 -= pi / 4;
          o2 += pi / 4;
        }
      }
      dx = Math.cos(o1) * source.width();
      dy = Math.sin(o1) * source.height();
      if (source === target) {
        dx *= 4;
        dy *= 4;
      }
      path = "" + path + " " + (a1.x + dx) + " " + (a1.y + dy);
      dx = Math.cos(o2) * target.width();
      dy = Math.sin(o2) * target.height();
      if (source === target) {
        dx *= 4;
        dy *= 4;
      }
      return path = "" + path + " " + (a2.x + dx) + " " + (a2.y + dy) + " " + a2.x + " " + a2.y;
    };

    return Rationalcurve;

  })(LinkStyle);

  Markers = {};

  Marker = (function(_super) {
    __extends(Marker, _super);

    Marker.prototype.margin = function() {
      return 6;
    };

    Marker.prototype.width = function() {
      return 20;
    };

    Marker.prototype.height = function() {
      return 20;
    };

    Marker.prototype.w = function() {
      if (this.start) {
        return this.width();
      } else {
        return -this.width();
      }
    };

    Marker.prototype.viewbox = function() {
      var h, lw, w;
      w = this.width() + this.margin();
      if (this.start) {
        lw = 0;
      } else {
        lw = this.margin() / 2 - w;
      }
      h = this.height() + this.margin();
      return "" + lw + " " + (-h / 2) + " " + w + " " + h;
    };

    function Marker(open, start) {
      this.open = open != null ? open : false;
      this.start = start != null ? start : false;
      Marker.__super__.constructor.apply(this, arguments);
      this.id = this.cls.name;
      this.open && (this.id += 'Open');
      this.start && (this.id += 'Start');
    }

    return Marker;

  })(Base);

  Markers.None = (function(_super) {
    __extends(None, _super);

    function None() {
      return None.__super__.constructor.apply(this, arguments);
    }

    None.prototype.path = function() {
      return 'M 0 0';
    };

    return None;

  })(Marker);

  Markers.Vee = (function(_super) {
    __extends(Vee, _super);

    function Vee() {
      return Vee.__super__.constructor.apply(this, arguments);
    }

    Vee.prototype.path = function() {
      var h, h2, lw, w;
      w = this.w();
      h = this.height();
      lw = w / 3;
      h2 = h / 2;
      return "M 0 0 L " + w + " " + (-h2) + " L " + lw + " 0 L " + w + " " + h2 + " z";
    };

    return Vee;

  })(Marker);

  Markers.Crow = (function(_super) {
    __extends(Crow, _super);

    function Crow() {
      return Crow.__super__.constructor.apply(this, arguments);
    }

    Crow.prototype.path = function() {
      var h, h2, lw, w;
      w = this.w();
      h = this.height();
      lw = 2 * w / 3;
      h2 = h / 2;
      return "M 0 " + (-h2) + " L " + w + " 0 L 0 " + h2 + " L " + lw + " 0 z";
    };

    return Crow;

  })(Marker);

  Markers.Normal = (function(_super) {
    __extends(Normal, _super);

    function Normal() {
      return Normal.__super__.constructor.apply(this, arguments);
    }

    Normal.prototype.path = function() {
      var h2, w;
      w = this.w();
      h2 = this.height() / 2;
      return "M 0 0 L " + w + " " + (-h2) + " L " + w + " " + h2 + " z";
    };

    return Normal;

  })(Marker);

  Markers.Inv = (function(_super) {
    __extends(Inv, _super);

    function Inv() {
      return Inv.__super__.constructor.apply(this, arguments);
    }

    Inv.prototype.path = function() {
      var h2, w;
      w = this.w();
      h2 = this.height() / 2;
      return "M 0 " + (-h2) + " L " + w + " 0 L 0 " + h2 + " z";
    };

    return Inv;

  })(Marker);

  Markers.Diamond = (function(_super) {
    __extends(Diamond, _super);

    function Diamond() {
      return Diamond.__super__.constructor.apply(this, arguments);
    }

    Diamond.prototype.width = function() {
      return 40;
    };

    Diamond.prototype.path = function() {
      var h2, w, w2;
      w = this.w();
      w2 = w / 2;
      h2 = this.height() / 2;
      return "M 0 0 L " + w2 + " " + (-h2) + " L " + w + " 0 L " + w2 + " " + h2 + " z";
    };

    return Diamond;

  })(Marker);

  Markers.Dot = (function(_super) {
    __extends(Dot, _super);

    function Dot() {
      return Dot.__super__.constructor.apply(this, arguments);
    }

    Dot.prototype.path = function() {
      var h2, w, w2;
      w = this.w();
      w2 = w / 2;
      h2 = this.height() / 2;
      return "M 0 0 A " + (-w2) + " " + h2 + " 0 1 1 " + w + " 0 A " + (-w2) + " " + h2 + " 0 1 1 0 0";
    };

    return Dot;

  })(Marker);

  Markers.Box = (function(_super) {
    __extends(Box, _super);

    function Box() {
      return Box.__super__.constructor.apply(this, arguments);
    }

    Box.prototype.path = function() {
      var h2, w, w2;
      w = this.w();
      w2 = w / 2;
      h2 = this.height() / 2;
      return "M 0 " + (-h2) + " L 0 " + h2 + " L " + w + " " + h2 + " L " + w + " " + (-h2) + " z";
    };

    return Box;

  })(Marker);

  Markers.Tee = (function(_super) {
    __extends(Tee, _super);

    function Tee() {
      return Tee.__super__.constructor.apply(this, arguments);
    }

    Tee.prototype.width = function() {
      return 7.5;
    };

    return Tee;

  })(Markers.Box);

  marker_to_dot = function(m) {
    var name;
    name = m.cls.name.toLowerCase();
    if (m.open) {
      return "o" + name;
    } else {
      return name;
    }
  };

  Markers._get = function(type, start) {
    var m, open;
    if (start == null) {
      start = false;
    }
    open = false;
    if (type.indexOf('o') === 0) {
      type = type.slice(1);
      open = true;
    }
    type = capitalize(type.replace(/^Black/, ''));
    if (type && type in Markers) {
      return m = new Markers[type](open, start);
    } else {
      return m = new Markers.None(open, start);
    }
  };

  Markers._cycle = function(link, start) {
    var arrow, marker, type;
    if (start == null) {
      start = false;
    }
    arrow = start ? 'arrowtail' : 'arrowhead';
    marker = start ? 'marker_start' : 'marker_end';
    type = link.attrs[arrow] || marker_to_dot(link[marker] || link.cls[marker]);
    if (type.indexOf('o') === 0) {
      link.attrs[arrow] = type.slice('1');
    } else {
      link.attrs[arrow] = 'o' + next(Markers, Markers._get(type, start).cls.name);
    }
    return link[marker] = Markers._get(link.attrs[arrow], start);
  };

  Element = (function(_super) {
    __extends(Element, _super);

    Element.handle_size = 10;

    Element.resizeable = true;

    Element.rotationable = true;

    Element.fill = 'bg';

    Element.stroke = 'fg';

    function Element(x, y, text, fixed) {
      this.x = x;
      this.y = y;
      this.text = text;
      this.fixed = fixed != null ? fixed : false;
      Element.__super__.constructor.apply(this, arguments);
      this.ts = timestamp();
      this.margin = {
        x: 10,
        y: 5
      };
      this._width = null;
      this._height = null;
      this._rotation = 0;
      this.anchors = {};
      this.color = null;
      this.bg_color = null;
      this.anchors[cardinal.N] = (function(_this) {
        return function() {
          return {
            x: _this.x,
            y: _this.y - _this.height() / 2
          };
        };
      })(this);
      this.anchors[cardinal.E] = (function(_this) {
        return function() {
          return {
            x: _this.x + _this.width() / 2,
            y: _this.y
          };
        };
      })(this);
      this.anchors[cardinal.S] = (function(_this) {
        return function() {
          return {
            x: _this.x,
            y: _this.y + _this.height() / 2
          };
        };
      })(this);
      this.anchors[cardinal.W] = (function(_this) {
        return function() {
          return {
            x: _this.x - _this.width() / 2,
            y: _this.y
          };
        };
      })(this);
      this.handles = {
        NE: (function(_this) {
          return function() {
            return {
              x: _this.width() / 2,
              y: -_this.height() / 2
            };
          };
        })(this),
        NW: (function(_this) {
          return function() {
            return {
              x: -_this.width() / 2,
              y: -_this.height() / 2
            };
          };
        })(this),
        SW: (function(_this) {
          return function() {
            return {
              x: -_this.width() / 2,
              y: _this.height() / 2
            };
          };
        })(this),
        SE: (function(_this) {
          return function() {
            return {
              x: _this.width() / 2,
              y: _this.height() / 2
            };
          };
        })(this),
        O: (function(_this) {
          return function() {
            return {
              x: 0,
              y: -_this.height() / 2
            };
          };
        })(this)
      };
    }

    Element.prototype.rotate = function(pos, direct) {
      var ang, normed;
      if (direct == null) {
        direct = true;
      }
      if (void 0 === pos.x || void 0 === pos.y) {
        return null;
      }
      ang = direct ? this._rotation : 2 * pi - this._rotation;
      normed = {
        x: pos.x - this.x,
        y: pos.y - this.y
      };
      normed = rotate(normed, ang);
      normed.x += this.x;
      normed.y += this.y;
      return normed;
    };

    Element.prototype.anchor_list = function() {
      return [cardinal.N, cardinal.S, cardinal.W, cardinal.E];
    };

    Element.prototype.handle_list = function() {
      var l;
      l = [];
      if (this.cls.resizeable) {
        l = l.concat(['NW', 'NE', 'SW', 'SE']);
      }
      if (this.cls.rotationable) {
        l.push('O');
      }
      return l;
    };

    Element.prototype.pos = function() {
      return this.rotate({
        x: this.x,
        y: this.y
      });
    };

    Element.prototype.set_txt_bbox = function(bbox) {
      return this._txt_bbox = bbox;
    };

    Element.prototype.txt_width = function() {
      return this._txt_bbox.width + 2 * this.margin.x;
    };

    Element.prototype.txt_height = function() {
      return this._txt_bbox.height + 2 * this.margin.y;
    };

    Element.prototype.txt_x = function() {
      return 0;
    };

    Element.prototype.txt_y = function() {
      var lines;
      lines = this.text.split('\n').length;
      return this.margin.y - (this._txt_bbox.height * (lines - 1) / lines) / 2;
    };

    Element.prototype.width = function(w) {
      var _ref;
      if (w == null) {
        w = null;
      }
      if (w !== null) {
        return this._width = w;
      }
      if ((_ref = this.attrs) != null ? _ref.width : void 0) {
        this._width = this.attrs.width * this.txt_width();
        delete this.attrs.width;
      }
      return Math.max(this._width || 0, this.txt_width());
    };

    Element.prototype.height = function(h) {
      var _ref;
      if (h == null) {
        h = null;
      }
      if (h !== null) {
        return this._height = h;
      }
      if ((_ref = this.attrs) != null ? _ref.height : void 0) {
        this._height = this.attrs.height * this.txt_height();
        delete this.attrs.height;
      }
      return Math.max(this._height || 0, this.txt_height());
    };

    Element.prototype.direction = function(x, y) {
      var anchor, deviation, diff, min_anchor, min_diff, pi2, pos, target, _ref;
      pi2 = 2 * pi;
      target = atan2(y - this.y, x - this.x);
      min_diff = Infinity;
      _ref = this.anchors;
      for (anchor in _ref) {
        pos = _ref[anchor];
        deviation = target - (+anchor) - this._rotation;
        diff = Math.min(Math.abs(deviation) % pi2, Math.abs(deviation - pi2) % pi2);
        if (diff < min_diff) {
          min_diff = diff;
          min_anchor = anchor;
        }
      }
      return +min_anchor;
    };

    Element.prototype["in"] = function(rect) {
      var x, y;
      x = this.x * diagram.zoom.scale + diagram.zoom.translate[0];
      y = this.y * diagram.zoom.scale + diagram.zoom.translate[1];
      return (rect.x < x && x < rect.x + rect.width) && (rect.y < y && y < rect.y + rect.height);
    };

    Element.prototype.contains = function() {
      return false;
    };

    Element.prototype.objectify = function() {
      return {
        name: this.constructor.name,
        x: this.x,
        y: this.y,
        width: this._width,
        height: this._height,
        rotation: this._rotation,
        text: this.text,
        fixed: this.fixed,
        attrs: this.attrs
      };
    };

    return Element;

  })(Base);

  Mouse = (function(_super) {
    __extends(Mouse, _super);

    function Mouse() {
      return Mouse.__super__.constructor.apply(this, arguments);
    }

    Mouse.prototype.width = function() {
      return 1;
    };

    Mouse.prototype.height = function() {
      return 1;
    };

    Mouse.prototype.weight = 1;

    return Mouse;

  })(Element);

  Link = (function(_super) {
    __extends(Link, _super);

    Link.marker_start = new Markers.None(false, true);

    Link.marker_end = new Markers.None();

    Link.type = 'full';

    Link.prototype.text_margin = 10;

    function Link(source, target, text) {
      this.source = source;
      this.target = target;
      Link.__super__.constructor.apply(this, arguments);
      this.a1 = this.a2 = 0;
      this.text = {
        source: (text != null ? text.source : void 0) || '',
        target: (text != null ? text.target : void 0) || ''
      };
      this.color = null;
    }

    Link.prototype.objectify = function(elements) {
      if (elements == null) {
        elements = diagram.elements;
      }
      return {
        name: this.constructor.name,
        source: elements.indexOf(this.source),
        target: elements.indexOf(this.target),
        source_anchor: this.source_anchor,
        target_anchor: this.target_anchor,
        text: this.text,
        attrs: this.attrs
      };
    };

    Link.prototype.nearest = function(pos) {
      if (dist(pos, this.a1) < dist(pos, this.a2)) {
        return this.source;
      } else {
        return this.target;
      }
    };

    Link.prototype.path = function() {
      var c1, c2, d1, d2;
      c1 = this.source.pos();
      c2 = this.target.pos();
      if ((null === c1 || null === c2) || (void 0 === c1.x || void 0 === c1.y || void 0 === c2.x || void 0 === c2.y)) {
        return 'M 0 0';
      }
      if (this.source_anchor != null) {
        d1 = +this.source_anchor;
      } else {
        d1 = +this.source.direction(c2.x, c2.y);
      }
      this.a1 = this.source.rotate(this.source.anchors[d1]());
      if (this.target_anchor != null) {
        d2 = +this.target_anchor;
      } else {
        d2 = +this.target.direction(this.a1.x, this.a1.y);
      }
      if (this.source === this.target && d1 === d2) {
        d2 = +next(this.target.anchors, d1.toString());
      }
      this.a2 = this.target.rotate(this.target.anchors[d2]());
      this.o1 = d1 + this.source._rotation;
      this.o2 = d2 + this.target._rotation;
      return diagram.linkstyle.get(this.source, this.target, this.a1, this.a2, this.o1, this.o2);
    };

    return Link;

  })(Base);

  Diagram = (function(_super) {
    __extends(Diagram, _super);

    Diagram.init_types = function() {
      return {
        elements: {},
        links: {}
      };
    };

    function Diagram() {
      Diagram.__super__.constructor.apply(this, arguments);
      this.title = 'Untitled ' + this.label;
      this.linkstyle = new LinkStyles.Rectangular();
      this.zoom = {
        scale: 1,
        translate: [0, 0]
      };
      this.elements = [];
      this.links = [];
      this.snap = {
        x: 25,
        y: 25,
        a: 22.5
      };
      this.selection = [];
      this.linking = [];
      this.last_types = {
        link: null,
        element: null
      };
      this.force_conf = {
        gravity: .1,
        distance: 20,
        strengh: 1,
        friction: .9,
        theta: .8,
        charge_base: 2000
      };
    }

    Diagram.prototype.start_force = function() {
      this.force = d3.layout.force().gravity(this.force_conf.gravity).linkDistance(this.force_conf.distance).linkStrength(this.force_conf.strengh).friction(this.force_conf.friction).theta(this.force_conf.theta).charge((function(_this) {
        return function(node) {
          return -_this.force_conf.charge_base - node.width() * node.height() / 4;
        };
      })(this)).size([svg.width, svg.height]);
      this.force.on('tick', function() {
        return svg.tick();
      });
      this.force.on('end', generate_url);
      svg.sync();
      return this.force.start();
    };

    Diagram.prototype.markers = function() {
      var marker, markers, name;
      markers = [];
      for (name in Markers) {
        marker = Markers[name];
        if (name.indexOf('_') === 0) {
          continue;
        }
        markers.push(new marker(false, false));
        markers.push(new marker(true, false));
        markers.push(new marker(false, true));
        markers.push(new marker(true, true));
      }
      return markers;
    };

    Diagram.prototype.to_svg = function() {
      var content, css, margin, rect, rule, svg_clone, _i, _len, _ref, _ref1;
      css = '';
      _ref = d3.select('#style').node().sheet.cssRules;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        rule = _ref[_i];
        if ((_ref1 = rule.selectorText) != null ? _ref1.match(/^svg\s/) : void 0) {
          if (!rule.cssText.match(/:hover/) && !rule.cssText.match(/:active/) && !rule.cssText.match(/transition/)) {
            css += rule.cssText.replace(/svg\s/g, '');
          }
        }
      }
      svg_clone = d3.select(svg.svg.node().cloneNode(true));
      svg_clone.select('.background').remove();
      svg_clone.selectAll('.handles,.anchors').remove();
      svg_clone.selectAll('.element').classed('selected', false);
      svg_clone.selectAll('.ghost').remove();
      svg_clone.select('defs').append('style').text(css);
      margin = 50;
      rect = svg.svg.select('.root').node().getBoundingClientRect();
      svg_clone.select('.root').attr('transform', "translate(" + (diagram.zoom.translate[0] - rect.left + margin) + ", " + (diagram.zoom.translate[1] - rect.top + margin) + ") scale(" + diagram.zoom.scale + ")");
      svg_clone.select('#title').attr('x', rect.width / 2 + margin);
      svg_clone.append('image').attr('xlink:href', 'data:image/png;base64, iVBORw0KGgoAAAANSUhEUgAAAGQAAAAnCAYAAAD5Lu2WAAAABHNCSVQICAgIfAhkiAAAAAl wSFlzAAAEKQAABCkBfcZRfgAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPB oAAAfPSURBVGiB7Zp/bFPXFce/5z7b+QUJPxMYhYSqDQuidKloIAnaaiBpkqKsWcV7L6Vjs K1j7To6pm2q2kko60Q3dWpVtBVYW7VFBOIHBRFo4piiFTFIwo/BYIVN3fhRGHSUEaAhjsHv nv0RbJzEv5KYxs38kSz73nvOuee9r9+75z6bmBkJ4gcx2Akk6E5CkDgjIUickRAkzkgIEmd YojEqamoqgEQZEfVbQGYcuav96nZjwQKzvzH+H6BIZW9xo8vFhJKYTAacvSm9BfsrKj6NRT wflZWVqfX19R2xjDlYOYT9xs9yfjC7pxjFY8fi6dx7oWZPQobV2jsgEeaNH4cfTclF1cSJS FYU/xgDE63C8v2BJh2I3W63pKamXNQ07euxjNufHHRdnzXQWGFvWQqb5Uzkb79w3zQ8MuEr /va3756MH7TsxwW3G0CXGC8/kI/CsWP8NmrOJDzZ0or2m14AAAPlAH490MR95OTkWNzujjQ Ao2IVs785CCFHDDRW2CtECuH/ej8walQ3MQBgdFISnsq919+eMy6rmxgAkJ2WhkWTJ9/uIC hIEJKoF+kp6cOD92ekB9ikB7XJzQjeH88UNDSMC2wTQMUuV+adnjdqQc51BF+vzl3v6JONj 5qamm5z2+12C1HA/bEHS5cu7b1g9ZFIcwAA1dSIQufOSouwXChy7lzg6y90up5jiU9nO51T KCB3VVUVj8eTAQCmSWlVVVUjBpJrVGUvAOz97BKOtl3B9JG3b5M3pcRb//yXv+08fx5adjZ yhqX5+9q9Xqw/dbpXvBMnjtdqmvaxENzKTCuysjKna5p6Q9fV/VLiZ4ZhHCEi0jTtKYCfAZ Cr69o1gPcqiny2tnbzyWjyVlU1hYhWEKEsKyszT9NUj66rxwCsdzg2reGAMrPY6Xq6qKDwU VKwWHr5NcUqWv2BWDiJzDHy84xPCmcWtRQ6XX9oLit9VwhRK6WpAQARNicl2XD1alsrgH4t 8FELIpmx7MBBLMiehOkjR+CSx4P3zpzFyfZ2v43HlHiypRXVOdnITU/HebcbG0+dxn86O3v FI8J4AOXMNBzAGoB+BWAYwEuEoP26ri/UNFUDeD5Arwohd0spMgE8Y5rKUVVVZxuGcSRczq qqThWCtgDIAHg1EQ5JSWlEVAjgVVVVq6qqqtStW7deueWSKQmZzSUl5wH8JDDWvvJ5hwEcB oAi585MAsYDgM12Y5nHY32dCLsBWg6ghUj8O9rz2pOoBQGAG1Ki9tRp1J4KbXPd68WbAVdN BDIAUuvq6jYF9NXpuv4mwA4ALCXPMQzHbt+gqqq1RLRDCHqHiPIXL14cNLCqqilC0GaAz0i JasMwLgcMG6qqviEEvZ+UZFsNoDrahHuybt2Wi0uWLLnmdndACPn3DRuMlv7GAgb90Qm39h ADAKAoys8BMIB6wzB2B44ZhmES0U8B3P/444/dEyqyEOIFAKOEsCzsIYYvznEisRDAAl3X5 w/4UGLEoApCRB8F66+trW0DcAbgw8HG8/Ly/gHAK6WYFjq6nMeMdzZs2HAplMXGjRv3AbwP wLw+JX4HGVRBmHEzzPCNW69erFixQgIwmUVSsPGuSoqmE1HYNeaW7UdE/LWoEv4CGJJPe29 VTpcBOSayLY1kxohbflcIyIhihuCbshgwJAXpgg8z0zfCWdjtdguAB/0exEcA5MzctWt0KJ 9ZjY13ocdjGpvNZgJgZqQMLOchLAgzrSbCY7qul4ayGTcu85cA3+1rdwhxAMAFi9d8MZSPI MvKnn1r1669CeACM1UMNO8hK4jD4WgAaA3AhqZp3w0cq6ioSNI07WVmPA/AX6P/tbT0OjOW MuOHxY1Nv7V/+GGyb2zGjh2pxU7XKoCfAODtPSPtAfAtXdfDFBqR6dM+JJ4hwjJd12c6HI7 nfbtvKeWPiegsEVbruvYiwH8BKC09fXg+gOtScgkRlROhzBenubx0e7Fz5yImrPJ03vhekb PpIDEJm8U2g0HXwLCD8G5XVX4bKeUvhKA9AB/Tde0EQL+pq6tb19fjCCtIxF+v+gGz70j4j 8x0MYzl74mUvWHGVyqKt/ntt+s6dV1/BcAEZu5WdRmGYQJ4Sdf195h5DhHdB1AbgFfcbvfu bdu2fV5dXd3JzN22unvLStYXNDR8oCjW+YIxnQmdDLkmOTnZ9aeHHmovdLpeY8hdPeb6pLK yMi8lJWURgDwhpHXGoUNW22eX5zPJrFBHoZji4J8rSg762mHPeZFzZxXAW0KflL7DwKrmst JnYxkznpi2aZNt+LCMuc3lpY1FTtdzAF6K4MKKqdyz55G5J4EIa0hSsnU7gHMxyhUAJLO5N obx4o6MtBFTifB+UZNrK4imRuFCpsWb629EuivNrq8fblqTn6Cun3Lz+58qXybQCQbaI9t+ qRkNwjeJIZnQCMajET2Iy/c9/LCz62Piv70xpdjlmsYSR5ixkAjlAL4T0SlAkCFb9g4We0t L/2Zalazm8lJHf/wTgtwBWufO/W9/fROCfAHkjxqJ5XlfxYTUVKzMvx/DLBa8XvBgUNshsz GMZw5fbsPxq1fhMSVqjh6Dx5RYfuhQUNvEFXIHYcbHvs8eUwZ9B8BSCP/jm8QVcgcZCfN3V 2A5CQ69U2eIAy0lJX7hEmVvnJG4ZcUZCUHijIQgccb/AGU94E0OVgKPAAAAAElFTkSuQmCC').attr('x', 10).attr('width', 100).attr('y', rect.height + 50).attr('height', 39);
      content = svg_clone.html();
      if (content == null) {
        content = $(svg_clone.node()).wrap('<div>').parent().html();
      }
      return "<svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' width='" + (rect.width + 2 * margin) + "' height='" + (rect.height + 2 * margin) + "'> <!-- Generated with umlaut (http://kozea.github.io/umlaut/) (c) Mounier Florian Kozea 2013 on " + ((new Date()).toString()) + "--> " + content + " </svg>";
    };

    Diagram.prototype.objectify = function() {
      return {
        name: this.constructor.name,
        title: this.title,
        linkstyle: this.linkstyle.cls.name,
        zoom: this.zoom,
        elements: this.elements.map(function(elt) {
          return elt.objectify();
        }),
        links: this.links.map(function(lnk) {
          return lnk.objectify();
        }),
        force: this.force ? true : false
      };
    };

    Diagram.prototype.hash = function() {
      return LZString.compressToBase64(JSON.stringify(this.objectify()));
    };

    Diagram.prototype.loads = function(obj) {
      var elt, lnk, _i, _j, _len, _len1, _ref, _ref1;
      if (obj.title) {
        this.title = obj.title;
      }
      if (obj.linkstyle) {
        this.linkstyle = new LinkStyles[capitalize(obj.linkstyle)]();
      }
      if (obj.zoom) {
        this.zoom = obj.zoom;
      }
      _ref = obj.elements;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        elt = _ref[_i];
        this.elements.push(this.elementify(elt));
      }
      _ref1 = obj.links;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        lnk = _ref1[_j];
        this.links.push(this.linkify(lnk));
      }
      if (obj.force) {
        return this.start_force();
      }
    };

    Diagram.prototype.elementify = function(elt) {
      var element, element_type;
      element_type = this.types.elements[elt.name];
      element = new element_type(elt.x, elt.y, elt.text, false);
      element._width = elt.width || null;
      element._height = elt.height || null;
      element._rotation = elt.rotation || 0;
      element.attrs = o_copy(elt.attrs || {});
      return element;
    };

    Diagram.prototype.linkify = function(lnk, elements) {
      var link, link_type;
      if (elements == null) {
        elements = this.elements;
      }
      link_type = this.types.links[lnk.name] || this.types.links['Link'];
      link = new link_type(elements[lnk.source], elements[lnk.target], lnk.text);
      link.source_anchor = lnk.source_anchor;
      link.target_anchor = lnk.target_anchor;
      link.attrs = o_copy(lnk.attrs || {});
      if (link.attrs.arrowhead) {
        link.marker_end = Markers._get(link.attrs.arrowhead);
      }
      if (link.attrs.arrowtail) {
        link.marker_start = Markers._get(link.attrs.arrowtail, true);
      }
      return link;
    };

    return Diagram;

  })(Base);

  Diagrams = {
    _get: function(type) {
      return this[type] || this[type.replace('Diagram', '')];
    }
  };

  Rect = (function(_super) {
    __extends(Rect, _super);

    function Rect() {
      return Rect.__super__.constructor.apply(this, arguments);
    }

    Rect.prototype.path = function() {
      var h2, w2;
      w2 = this.width() / 2;
      h2 = this.height() / 2;
      return "M " + (-w2) + " " + (-h2) + " L " + w2 + " " + (-h2) + " L " + w2 + " " + h2 + " L " + (-w2) + " " + h2 + " z";
    };

    return Rect;

  })(Element);

  Ellipsis = (function(_super) {
    __extends(Ellipsis, _super);

    function Ellipsis() {
      return Ellipsis.__super__.constructor.apply(this, arguments);
    }

    Ellipsis.prototype.txt_width = function() {
      return 2 * Ellipsis.__super__.txt_width.call(this) / Math.sqrt(2);
    };

    Ellipsis.prototype.txt_height = function() {
      return 2 * Ellipsis.__super__.txt_height.call(this) / Math.sqrt(2);
    };

    Ellipsis.prototype.path = function() {
      var h2, w2;
      w2 = this.width() / 2;
      h2 = this.height() / 2;
      return "M " + (-w2) + " 0 A " + w2 + " " + h2 + " 0 1 1 " + w2 + " 0 A " + w2 + " " + h2 + " 0 1 1 " + (-w2) + " 0";
    };

    return Ellipsis;

  })(Element);

  Note = (function(_super) {
    __extends(Note, _super);

    function Note() {
      return Note.__super__.constructor.apply(this, arguments);
    }

    Note.prototype.shift = 15;

    Note.prototype.txt_width = function() {
      return Note.__super__.txt_width.call(this) + this.shift;
    };

    Note.prototype.txt_x = function() {
      return Note.__super__.txt_x.call(this) - this.shift / 2;
    };

    Note.prototype.txt_y = function() {
      return Note.__super__.txt_y.call(this);
    };

    Note.prototype.path = function() {
      var h2, w2;
      w2 = this.width() / 2;
      h2 = this.height() / 2;
      return "M " + (-w2) + " " + (-h2) + " L " + (w2 - this.shift) + " " + (-h2) + " L " + w2 + " " + (-h2 + this.shift) + " L " + w2 + " " + h2 + " L " + (-w2) + " " + h2 + " L " + (-w2) + " " + (-h2 + this.shift) + " z M " + w2 + " " + (-h2 + this.shift) + " L " + (w2 - this.shift) + " " + (-h2 + this.shift) + " L " + (w2 - this.shift) + " " + (-h2);
    };

    return Note;

  })(Element);

  Lozenge = (function(_super) {
    __extends(Lozenge, _super);

    function Lozenge() {
      return Lozenge.__super__.constructor.apply(this, arguments);
    }

    Lozenge.prototype.txt_width = function() {
      var ow;
      ow = Lozenge.__super__.txt_width.call(this);
      return ow + Math.sqrt(ow * this["super"]('txt_height', Lozenge));
    };

    Lozenge.prototype.txt_height = function() {
      var oh;
      oh = Lozenge.__super__.txt_height.call(this);
      return oh + Math.sqrt(oh * this["super"]('txt_width', Lozenge));
    };

    Lozenge.prototype.path = function() {
      var h2, w2;
      w2 = this.width() / 2;
      h2 = this.height() / 2;
      return "M " + (-w2) + " 0 L 0 " + (-h2) + " L " + w2 + " 0 L 0 " + h2 + " z";
    };

    return Lozenge;

  })(Element);

  Triangle = (function(_super) {
    __extends(Triangle, _super);

    function Triangle() {
      return Triangle.__super__.constructor.apply(this, arguments);
    }

    Triangle.prototype.txt_width = function() {
      return Triangle.__super__.txt_width.call(this) * 2;
    };

    Triangle.prototype.txt_height = function() {
      return Triangle.__super__.txt_height.call(this) * 2;
    };

    Triangle.prototype.txt_y = function() {
      return Triangle.__super__.txt_y.call(this) + this.txt_height() / 4;
    };

    Triangle.prototype.path = function() {
      var h2, w2;
      w2 = this.width() / 2;
      h2 = this.height() / 2;
      return "M 0 " + (-h2) + " L " + w2 + " " + h2 + " L " + (-w2) + " " + h2 + " z";
    };

    return Triangle;

  })(Element);

  Parallelogram = (function(_super) {
    __extends(Parallelogram, _super);

    function Parallelogram() {
      Parallelogram.__super__.constructor.apply(this, arguments);
      this.anchors[cardinal.E] = (function(_this) {
        return function() {
          return {
            x: _this.x + _this.width() / 2 - _this.height() / 4,
            y: _this.y
          };
        };
      })(this);
      this.anchors[cardinal.W] = (function(_this) {
        return function() {
          return {
            x: _this.x - _this.width() / 2 + _this.height() / 4,
            y: _this.y
          };
        };
      })(this);
    }

    Parallelogram.prototype.txt_width = function() {
      return Parallelogram.__super__.txt_width.call(this) + this.height();
    };

    Parallelogram.prototype.path = function() {
      var h2, lw2, w2;
      w2 = (this.width() - this.height()) / 2;
      h2 = this.height() / 2;
      lw2 = this.width() / 2;
      return "M " + (-lw2) + " " + (-h2) + " L " + w2 + " " + (-h2) + " L " + lw2 + " " + h2 + " L " + (-w2) + " " + h2 + " z";
    };

    return Parallelogram;

  })(Element);

  Trapezium = (function(_super) {
    __extends(Trapezium, _super);

    function Trapezium() {
      return Trapezium.__super__.constructor.apply(this, arguments);
    }

    Trapezium.prototype.path = function() {
      var h2, lw2, w2;
      w2 = (this.width() - this.height()) / 2;
      h2 = this.height() / 2;
      lw2 = this.width() / 2;
      return "M " + (-w2) + " " + (-h2) + " L " + w2 + " " + (-h2) + " L " + lw2 + " " + h2 + " L " + (-lw2) + " " + h2 + " z";
    };

    return Trapezium;

  })(Parallelogram);

  House = (function(_super) {
    __extends(House, _super);

    House.prototype.shift = 1.5;

    function House() {
      House.__super__.constructor.apply(this, arguments);
      this.anchors[cardinal.N] = (function(_this) {
        return function() {
          return {
            x: _this.x,
            y: _this.y - 3 * _this.shift_height() / 2
          };
        };
      })(this);
      this.anchors[cardinal.W] = (function(_this) {
        return function() {
          return {
            x: _this.x - _this.width() / 2,
            y: _this.y + _this.shift_height() / 2
          };
        };
      })(this);
      this.anchors[cardinal.E] = (function(_this) {
        return function() {
          return {
            x: _this.x + _this.width() / 2,
            y: _this.y + _this.shift_height() / 2
          };
        };
      })(this);
    }

    House.prototype.shift_height = function() {
      return this.height() * (this.shift - 1) / this.shift;
    };

    House.prototype.txt_height = function() {
      return House.__super__.txt_height.call(this) * this.shift;
    };

    House.prototype.txt_y = function() {
      return House.__super__.txt_y.call(this) + this.shift_height() / 2;
    };

    House.prototype.path = function() {
      var h2, th2, w2;
      w2 = this.width() / 2;
      h2 = this.height() / 2;
      th2 = h2 - this.shift_height();
      return "M " + (-w2) + " " + (-th2) + " L 0 " + (-h2) + " L " + w2 + " " + (-th2) + " L " + w2 + " " + h2 + " L " + (-w2) + " " + h2 + " z";
    };

    return House;

  })(Element);

  Polygon = (function(_super) {
    __extends(Polygon, _super);

    Polygon.prototype.n = 4;

    Polygon.prototype.shift = pi / 4;

    Polygon.prototype._x = function(a) {
      var o, r, w2;
      o = pi / this.n;
      w2 = this.width() / 2;
      return r = w2 * (Math.cos(o) / (Math.cos((a + this.shift) % (2 * o) - o))) * Math.cos(a - pi / 2);
    };

    Polygon.prototype._y = function(a) {
      var h2, o, r;
      o = pi / this.n;
      h2 = this.height() / 2;
      return r = h2 * (Math.cos(o) / (Math.cos((a + this.shift) % (2 * o) - o))) * Math.sin(a - pi / 2);
    };

    function Polygon() {
      Polygon.__super__.constructor.apply(this, arguments);
      this.anchors[cardinal.N] = (function(_this) {
        return function() {
          return {
            x: _this.x + _this._x(0),
            y: _this.y + _this._y(0)
          };
        };
      })(this);
      this.anchors[cardinal.E] = (function(_this) {
        return function() {
          return {
            x: _this.x + _this._x(pi / 2),
            y: _this.y + _this._y(pi / 2)
          };
        };
      })(this);
      this.anchors[cardinal.S] = (function(_this) {
        return function() {
          return {
            x: _this.x + _this._x(pi),
            y: _this.y + _this._y(pi)
          };
        };
      })(this);
      this.anchors[cardinal.W] = (function(_this) {
        return function() {
          return {
            x: _this.x + _this._x(3 * pi / 2),
            y: _this.y + _this._y(3 * pi / 2)
          };
        };
      })(this);
    }

    Polygon.prototype.txt_width = function() {
      return Polygon.__super__.txt_width.call(this) * 2;
    };

    Polygon.prototype.txt_height = function() {
      return Polygon.__super__.txt_height.call(this) * 2;
    };

    Polygon.prototype.path = function() {
      var angle, h2, i, path, w2, _i, _ref;
      w2 = this.width() / 2;
      h2 = this.height() / 2;
      angle = 2 * pi / this.n;
      path = '';
      for (i = _i = 0, _ref = this.n; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
        path = "" + path + " " + (i === 0 ? 'M' : 'L') + " " + (w2 * Math.sin(i * angle + this.shift)) + " " + (-h2 * Math.cos(i * angle + this.shift));
      }
      return "" + path + " z";
    };

    return Polygon;

  })(Element);

  Triangle = (function(_super) {
    __extends(Triangle, _super);

    function Triangle() {
      return Triangle.__super__.constructor.apply(this, arguments);
    }

    Triangle.prototype.n = 3;

    Triangle.prototype.shift = 0;

    return Triangle;

  })(Polygon);

  Pentagon = (function(_super) {
    __extends(Pentagon, _super);

    function Pentagon() {
      return Pentagon.__super__.constructor.apply(this, arguments);
    }

    Pentagon.prototype.n = 5;

    Pentagon.prototype.shift = 0;

    return Pentagon;

  })(Polygon);

  Hexagon = (function(_super) {
    __extends(Hexagon, _super);

    function Hexagon() {
      return Hexagon.__super__.constructor.apply(this, arguments);
    }

    Hexagon.prototype.n = 6;

    Hexagon.prototype.shift = pi / 6;

    return Hexagon;

  })(Polygon);

  Septagon = (function(_super) {
    __extends(Septagon, _super);

    function Septagon() {
      return Septagon.__super__.constructor.apply(this, arguments);
    }

    Septagon.prototype.n = 7;

    Septagon.prototype.shift = 0;

    return Septagon;

  })(Polygon);

  Octogon = (function(_super) {
    __extends(Octogon, _super);

    function Octogon() {
      return Octogon.__super__.constructor.apply(this, arguments);
    }

    Octogon.prototype.n = 8;

    Octogon.prototype.shift = pi / 8;

    return Octogon;

  })(Polygon);

  Star = (function(_super) {
    __extends(Star, _super);

    function Star() {
      return Star.__super__.constructor.apply(this, arguments);
    }

    Star.prototype.txt_width = function() {
      return Star.__super__.txt_width.call(this) * 5 * pi / (6 * 1.25);
    };

    Star.prototype.txt_height = function() {
      return Star.__super__.txt_height.call(this) * 5 * pi / (6 * 1.25);
    };

    Star.prototype.path = function() {
      var angle, h2, i, lh2, lw2, magic, path, w2, _i, _ref;
      angle = 2 * pi / this.n;
      w2 = this.width() / 2;
      h2 = this.height() / 2;
      magic = 5 * pi / 6;
      lw2 = w2 / magic;
      lh2 = h2 / magic;
      path = "M 0 " + (-h2);
      for (i = _i = 0, _ref = this.n; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
        path = "" + path + " L " + (w2 * Math.sin(i * angle)) + " " + (-h2 * Math.cos(i * angle)) + " L " + (lw2 * Math.sin((i + .5) * angle)) + " " + (-lh2 * Math.cos((i + .5) * angle));
      }
      return "" + path + " z";
    };

    return Star;

  })(Pentagon);

  Association = (function(_super) {
    __extends(Association, _super);

    function Association() {
      return Association.__super__.constructor.apply(this, arguments);
    }

    Association.marker_end = new Markers.Normal();

    return Association;

  })(Link);

  Inheritance = (function(_super) {
    __extends(Inheritance, _super);

    function Inheritance() {
      return Inheritance.__super__.constructor.apply(this, arguments);
    }

    Inheritance.marker_end = new Markers.Normal(true);

    return Inheritance;

  })(Link);

  Composition = (function(_super) {
    __extends(Composition, _super);

    function Composition() {
      return Composition.__super__.constructor.apply(this, arguments);
    }

    Composition.marker_end = new Markers.Diamond();

    return Composition;

  })(Link);

  Comment = (function(_super) {
    __extends(Comment, _super);

    function Comment() {
      return Comment.__super__.constructor.apply(this, arguments);
    }

    Comment.marker_end = new Markers.Vee();

    Comment.type = 'dashed';

    return Comment;

  })(Link);

  Aggregation = (function(_super) {
    __extends(Aggregation, _super);

    function Aggregation() {
      return Aggregation.__super__.constructor.apply(this, arguments);
    }

    Aggregation.marker_end = new Markers.Diamond(true);

    return Aggregation;

  })(Link);

  Group = (function(_super) {
    __extends(Group, _super);

    function Group() {
      return Group.__super__.constructor.apply(this, arguments);
    }

    Group.prototype.contains = function(elt) {
      var h2, w2, _ref, _ref1;
      w2 = this.width() / 2;
      h2 = this.height() / 2;
      return (this.x - w2 < (_ref = elt.x) && _ref < this.x + w2) && (this.y - h2 < (_ref1 = elt.y) && _ref1 < this.y + h2);
    };

    Group.prototype.txt_y = function() {
      var lines;
      lines = this.text.split('\n').length;
      return this.margin.y - this.height() / 2 + this._txt_bbox.height - (this._txt_bbox.height * (lines - 1) / lines);
    };

    Group.prototype.path = function() {
      var h2, h2l, w2;
      w2 = this.width() / 2;
      h2 = this.height() / 2;
      h2l = -h2 + this.txt_height() + this.margin.y;
      return "M " + (-w2) + " " + (-h2) + " L " + w2 + " " + (-h2) + " L " + w2 + " " + h2l + " L " + (-w2) + " " + h2l + " z M " + w2 + " " + h2l + " L " + w2 + " " + h2 + " M " + (-w2) + " " + h2l + " L " + (-w2) + " " + h2 + " M " + (-w2) + " " + h2 + " L " + w2 + " " + h2;
    };

    return Group;

  })(Element);

  Diagrams.FlowChart = (function(_super) {
    __extends(FlowChart, _super);

    function FlowChart() {
      return FlowChart.__super__.constructor.apply(this, arguments);
    }

    FlowChart.prototype.label = 'Flow Chart';

    FlowChart.prototype.types = FlowChart.init_types();

    return FlowChart;

  })(Diagram);

  E = Diagrams.FlowChart.prototype.types.elements;

  E.Process = (function(_super) {
    __extends(Process, _super);

    function Process() {
      return Process.__super__.constructor.apply(this, arguments);
    }

    return Process;

  })(Rect);

  E.IO = (function(_super) {
    __extends(IO, _super);

    function IO() {
      return IO.__super__.constructor.apply(this, arguments);
    }

    return IO;

  })(Parallelogram);

  E.Terminator = (function(_super) {
    __extends(Terminator, _super);

    function Terminator() {
      return Terminator.__super__.constructor.apply(this, arguments);
    }

    Terminator.prototype.path = function() {
      var h2, shift, w2;
      w2 = this.width() / 2;
      h2 = this.height() / 2;
      shift = Math.min(w2 / 2, h2 / 2);
      return "M " + (-w2 + shift) + " " + (-h2) + " L " + (w2 - shift) + " " + (-h2) + " Q " + w2 + " " + (-h2) + " " + w2 + " " + (-h2 + shift) + " L " + w2 + " " + (h2 - shift) + " Q " + w2 + " " + h2 + " " + (w2 - shift) + " " + h2 + " L " + (-w2 + shift) + " " + h2 + " Q " + (-w2) + " " + h2 + " " + (-w2) + " " + (h2 - shift) + " L " + (-w2) + " " + (-h2 + shift) + " Q " + (-w2) + " " + (-h2) + " " + (-w2 + shift) + " " + (-h2);
    };

    return Terminator;

  })(Element);

  E.Decision = (function(_super) {
    __extends(Decision, _super);

    function Decision() {
      return Decision.__super__.constructor.apply(this, arguments);
    }

    return Decision;

  })(Lozenge);

  E.Delay = (function(_super) {
    __extends(Delay, _super);

    function Delay() {
      Delay.__super__.constructor.apply(this, arguments);
      this.anchors[cardinal.N] = (function(_this) {
        return function() {
          return {
            x: _this.x + _this.txt_x(),
            y: _this.y - _this.height() / 2
          };
        };
      })(this);
      this.anchors[cardinal.S] = (function(_this) {
        return function() {
          return {
            x: _this.x + _this.txt_x(),
            y: _this.y + _this.height() / 2
          };
        };
      })(this);
    }

    Delay.prototype.txt_x = function() {
      return Delay.__super__.txt_x.call(this) - this.height() / 4 + this.txt_height() / 6;
    };

    Delay.prototype.txt_width = function() {
      return Math.max(0, Delay.__super__.txt_width.call(this) - this.txt_height() / 3) + this.height() / 2;
    };

    Delay.prototype.path = function() {
      var h2, w2;
      w2 = this.width() / 2;
      h2 = this.height() / 2;
      return "M " + (-w2) + " " + (-h2) + " L " + (w2 - h2) + " " + (-h2) + " A " + h2 + " " + h2 + " 0 1 1 " + (w2 - h2) + " " + h2 + " L " + (-w2) + " " + h2 + " z";
    };

    return Delay;

  })(Element);

  E.SubProcess = (function(_super) {
    __extends(SubProcess, _super);

    function SubProcess() {
      return SubProcess.__super__.constructor.apply(this, arguments);
    }

    SubProcess.prototype.shift = 1.2;

    SubProcess.prototype.txt_width = function() {
      return SubProcess.__super__.txt_width.call(this) * this.shift;
    };

    SubProcess.prototype.shift_width = function() {
      return this.width() * (this.shift - 1) / this.shift;
    };

    SubProcess.prototype.path = function() {
      var h2, lw2, w2;
      w2 = this.width() / 2;
      lw2 = w2 - this.shift_width() / 2;
      h2 = this.height() / 2;
      return "" + (SubProcess.__super__.path.call(this)) + " M " + (-lw2) + " " + (-h2) + " L " + (-lw2) + " " + h2 + " M " + lw2 + " " + (-h2) + " L " + lw2 + " " + h2;
    };

    return SubProcess;

  })(E.Process);

  E.Document = (function(_super) {
    __extends(Document, _super);

    function Document() {
      return Document.__super__.constructor.apply(this, arguments);
    }

    Document.prototype.txt_height = function() {
      return Document.__super__.txt_height.call(this) * 1.25;
    };

    Document.prototype.txt_y = function() {
      return Document.__super__.txt_y.call(this) - this.height() / 16;
    };

    Document.prototype.path = function() {
      var h2, w2;
      w2 = this.width() / 2;
      h2 = this.height() / 2;
      return "M " + (-w2) + " " + (-h2) + " L " + w2 + " " + (-h2) + " L " + w2 + " " + h2 + " Q " + (w2 / 2) + " " + (h2 / 2) + " 0 " + h2 + " T " + (-w2) + " " + h2 + " z";
    };

    return Document;

  })(Element);

  E.Database = (function(_super) {
    __extends(Database, _super);

    function Database() {
      return Database.__super__.constructor.apply(this, arguments);
    }

    Database.prototype.txt_y = function() {
      return Database.__super__.txt_y.call(this) + this.radius() / 2;
    };

    Database.prototype.txt_height = function() {
      return Database.__super__.txt_height.call(this) + 20;
    };

    Database.prototype.radius = function() {
      return Math.min((this.height() - this["super"]('txt_height')) / 4, this.width() / 3);
    };

    Database.prototype.path = function() {
      var h2, r, w2;
      w2 = this.width() / 2;
      h2 = this.height() / 2;
      r = this.radius();
      return "M " + (-w2) + " " + (-h2 + r) + " A " + w2 + " " + r + " 0 1 1 " + w2 + " " + (-h2 + r) + " A " + w2 + " " + r + " 0 1 1 " + (-w2) + " " + (-h2 + r) + " M " + w2 + " " + (-h2 + r) + " L " + w2 + " " + (h2 - r) + " A " + w2 + " " + r + " 0 1 1 " + (-w2) + " " + (h2 - r) + " L " + (-w2) + " " + (-h2 + r);
    };

    return Database;

  })(Element);

  E.HardDisk = (function(_super) {
    __extends(HardDisk, _super);

    function HardDisk() {
      return HardDisk.__super__.constructor.apply(this, arguments);
    }

    HardDisk.prototype.txt_x = function() {
      return HardDisk.__super__.txt_x.call(this) - this.radius() / 2;
    };

    HardDisk.prototype.txt_width = function() {
      return HardDisk.__super__.txt_width.call(this) + 20;
    };

    HardDisk.prototype.radius = function() {
      return Math.min((this.width() - this["super"]('txt_width')) / 4, this.height() / 3);
    };

    HardDisk.prototype.path = function() {
      var h2, r, w2;
      w2 = this.width() / 2;
      h2 = this.height() / 2;
      r = this.radius();
      return "M " + (w2 - r) + " " + h2 + " A " + r + " " + h2 + " 0 1 1 " + (w2 - r) + " " + (-h2) + " A " + r + " " + h2 + " 0 1 1 " + (w2 - r) + " " + h2 + " L " + (-w2 + r) + " " + h2 + " A " + r + " " + h2 + " 0 1 1 " + (-w2 + r) + " " + (-h2) + " L " + (w2 - r) + " " + (-h2);
    };

    return HardDisk;

  })(Element);

  E.ManualInput = (function(_super) {
    __extends(ManualInput, _super);

    ManualInput.prototype.shift = 2;

    function ManualInput() {
      ManualInput.__super__.constructor.apply(this, arguments);
      this.anchors[cardinal.N] = (function(_this) {
        return function() {
          return {
            x: _this.x,
            y: _this.y - _this.shift_height() / 2
          };
        };
      })(this);
      this.anchors[cardinal.W] = (function(_this) {
        return function() {
          return {
            x: _this.x - _this.width() / 2,
            y: _this.y + _this.shift_height() / 2
          };
        };
      })(this);
    }

    ManualInput.prototype.shift_height = function() {
      return this.height() * (this.shift - 1) / this.shift;
    };

    ManualInput.prototype.txt_height = function() {
      return ManualInput.__super__.txt_height.call(this) * this.shift;
    };

    ManualInput.prototype.txt_y = function() {
      return ManualInput.__super__.txt_y.call(this) + this.shift_height() / 2;
    };

    ManualInput.prototype.path = function() {
      var h2, th2, w2;
      w2 = this.width() / 2;
      h2 = this.height() / 2;
      th2 = h2 - this.shift_height();
      return "M " + (-w2) + " " + (-th2) + " L " + w2 + " " + (-h2) + " L " + w2 + " " + h2 + " L " + (-w2) + " " + h2 + " z";
    };

    return ManualInput;

  })(Element);

  E.Preparation = (function(_super) {
    __extends(Preparation, _super);

    function Preparation() {
      return Preparation.__super__.constructor.apply(this, arguments);
    }

    return Preparation;

  })(Hexagon);

  E.InternalStorage = (function(_super) {
    __extends(InternalStorage, _super);

    function InternalStorage() {
      return InternalStorage.__super__.constructor.apply(this, arguments);
    }

    InternalStorage.prototype.hshift = 1.5;

    InternalStorage.prototype.wshift = 1.1;

    InternalStorage.prototype.txt_x = function() {
      return InternalStorage.__super__.txt_x.call(this) + this.shift_width() / 2;
    };

    InternalStorage.prototype.txt_y = function() {
      return InternalStorage.__super__.txt_y.call(this) + this.shift_height() / 2;
    };

    InternalStorage.prototype.txt_width = function() {
      return InternalStorage.__super__.txt_width.call(this) * this.wshift;
    };

    InternalStorage.prototype.txt_height = function() {
      return InternalStorage.__super__.txt_height.call(this) * this.hshift;
    };

    InternalStorage.prototype.shift_width = function() {
      return this.width() * (this.wshift - 1) / this.wshift;
    };

    InternalStorage.prototype.shift_height = function() {
      return this.height() * (this.hshift - 1) / this.hshift;
    };

    InternalStorage.prototype.path = function() {
      var h2, lh2, lw2, w2;
      w2 = this.width() / 2;
      lw2 = w2 - this.shift_width();
      h2 = this.height() / 2;
      lh2 = h2 - this.shift_height();
      return "" + (InternalStorage.__super__.path.call(this)) + " M " + (-lw2) + " " + (-h2) + " L " + (-lw2) + " " + h2 + " M " + (-w2) + " " + (-lh2) + " L " + w2 + " " + (-lh2);
    };

    return InternalStorage;

  })(E.Process);

  Diagrams.FlowChart.prototype.types.links.Flow = (function(_super) {
    __extends(Flow, _super);

    function Flow() {
      return Flow.__super__.constructor.apply(this, arguments);
    }

    Flow.marker_end = new Markers.Normal();

    return Flow;

  })(Link);

  Diagrams.FlowChart.prototype.types.elements.Container = (function(_super) {
    __extends(Container, _super);

    function Container() {
      return Container.__super__.constructor.apply(this, arguments);
    }

    return Container;

  })(Group);

  Diagrams.Dot = (function(_super) {
    __extends(Dot, _super);

    Dot.prototype.label = 'Dot diagram';

    Dot.prototype.types = Dot.init_types();

    function Dot() {
      Dot.__super__.constructor.apply(this, arguments);
      this.linkstyle = new LinkStyles.Curve();
    }

    Dot.prototype.markers = function() {
      var marker, markers, name;
      markers = [];
      for (name in Markers) {
        marker = Markers[name];
        if (name.indexOf('_') !== 0) {
          markers.push(new marker());
          markers.push(new marker(true));
          markers.push(new marker(false, true));
          markers.push(new marker(true, true));
        }
      }
      return markers;
    };

    Dot.prototype.to_dot = function() {
      var attrs, directed, dot, element, key, link, op, shape, val, _i, _j, _len, _len1, _ref, _ref1, _ref2, _ref3;
      directed = false;
      dot = "graph umlaut {\n";
      _ref = diagram.elements;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        element = _ref[_i];
        dot = "" + dot + "  \"" + element.text + "\"";
        attrs = [];
        shape = element.cls.name.toLowerCase();
        if (shape !== 'ellipse') {
          attrs.push("shape=" + shape);
        }
        if (element.width() !== element.txt_width()) {
          attrs.push("width=" + (element.width() / element.txt_width()));
        }
        if (element.height() !== element.txt_height()) {
          attrs.push("height=" + (element.height() / element.txt_height()));
        }
        if (!diagram.force) {
          attrs.push("pos=\"" + (element.x.toFixed()) + ", " + (element.y.toFixed()) + (element.fixed ? '!' : '') + "\"");
        }
        _ref1 = element.attrs;
        for (key in _ref1) {
          val = _ref1[key];
          if (key !== 'shape' && key !== 'label') {
            attrs.push("" + key + "=\"" + val + "\"");
          }
        }
        if (attrs.length) {
          dot = "" + dot + "[" + (attrs.join(',')) + "]";
        }
        dot = "" + dot + ";\n";
      }
      _ref2 = diagram.links;
      for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
        link = _ref2[_j];
        if (!link.marker_end) {
          op = '--';
        } else {
          op = '->';
          directed = true;
        }
        dot = "" + dot + "  \"" + link.source.text + "\" " + op + " \"" + link.target.text + "\"";
        attrs = [];
        if (link.marker_start) {
          attrs.push("arrowhead=" + (marker_to_dot(link.marker_start)));
        }
        if (link.marker_end) {
          attrs.push("arrowtail=" + (marker_to_dot(link.marker_end)));
        }
        if (link.text.source) {
          attrs.push("taillabel=\"" + link.text.source + "\"");
        }
        if (link.text.target) {
          attrs.push("headlabel=\"" + link.text.target + "\"");
        }
        _ref3 = link.attrs;
        for (key in _ref3) {
          val = _ref3[key];
          if (key !== 'arrowhead' && key !== 'arrowtail' && key !== 'headlabel' && key !== 'taillabel') {
            attrs.push("" + key + "=\"" + val + "\"");
          }
        }
        if (attrs.length) {
          dot = "" + dot + "[" + (attrs.join(',')) + "]";
        }
        dot = "" + dot + ";\n";
      }
      dot = "" + dot + "}";
      if (directed) {
        dot = "di" + dot;
      }
      return dot;
    };

    return Dot;

  })(Diagram);

  E = Diagrams.Dot.prototype.types.elements;

  L = Diagrams.Dot.prototype.types.links;

  E.Box = (function(_super) {
    __extends(Box, _super);

    function Box() {
      return Box.__super__.constructor.apply(this, arguments);
    }

    return Box;

  })(Rect);

  E.Polygon = (function(_super) {
    __extends(Polygon, _super);

    function Polygon() {
      return Polygon.__super__.constructor.apply(this, arguments);
    }

    return Polygon;

  })(Polygon);

  E.Ellipse = (function(_super) {
    __extends(Ellipse, _super);

    function Ellipse() {
      return Ellipse.__super__.constructor.apply(this, arguments);
    }

    return Ellipse;

  })(Ellipsis);

  E.Oval = (function(_super) {
    __extends(Oval, _super);

    function Oval() {
      return Oval.__super__.constructor.apply(this, arguments);
    }

    Oval.alias = true;

    return Oval;

  })(E.Ellipse);

  E.Circle = (function(_super) {
    __extends(Circle, _super);

    function Circle() {
      return Circle.__super__.constructor.apply(this, arguments);
    }

    Circle.prototype.txt_height = function() {
      return Math.max(Circle.__super__.txt_height.call(this), this["super"]('txt_width'));
    };

    Circle.prototype.txt_width = function() {
      return Math.max(Circle.__super__.txt_width.call(this), this["super"]('txt_height'));
    };

    return Circle;

  })(E.Ellipse);

  E.Point = (function(_super) {
    __extends(Point, _super);

    Point.fill = 'fg';

    function Point() {
      Point.__super__.constructor.apply(this, arguments);
      this.margin.x = 0;
      this.margin.y = 0;
      this.text = '';
    }

    Point.prototype.txt_width = function() {
      return 5;
    };

    Point.prototype.txt_height = function() {
      return 5;
    };

    Point.prototype.path = function() {
      var h2, w2;
      w2 = this.width() / 2;
      h2 = this.height() / 2;
      return "M 0 " + (-h2) + " A " + w2 + " " + h2 + " 0 0 1 0 " + h2 + " A " + w2 + " " + h2 + " 0 0 1 0 " + (-h2);
    };

    return Point;

  })(Element);

  E.Egg = (function(_super) {
    __extends(Egg, _super);

    Egg.prototype.shift = 1.5;

    function Egg() {
      var magic;
      Egg.__super__.constructor.apply(this, arguments);
      magic = 1.051;
      this.anchors[cardinal.E] = (function(_this) {
        return function() {
          return {
            x: _this.x + magic * _this.width() / (4 - _this.shift),
            y: _this.y + _this.height() / 8
          };
        };
      })(this);
      this.anchors[cardinal.W] = (function(_this) {
        return function() {
          return {
            x: _this.x - magic * _this.width() / (4 - _this.shift),
            y: _this.y + _this.height() / 8
          };
        };
      })(this);
    }

    Egg.prototype.path = function() {
      var h2, w2;
      w2 = this.width() / 2;
      h2 = this.height() / 2;
      return "M 0 " + (-h2) + " C " + (w2 / this.shift) + " " + (-h2) + " " + (w2 * this.shift) + " " + h2 + " 0 " + h2 + " C " + (-w2 * this.shift) + " " + h2 + " " + (-w2 / this.shift) + " " + (-h2) + " 0 " + (-h2);
    };

    return Egg;

  })(E.Ellipse);

  E.Triangle = (function(_super) {
    __extends(Triangle, _super);

    function Triangle() {
      return Triangle.__super__.constructor.apply(this, arguments);
    }

    return Triangle;

  })(Triangle);

  E.Plaintext = (function(_super) {
    __extends(Plaintext, _super);

    function Plaintext() {
      return Plaintext.__super__.constructor.apply(this, arguments);
    }

    Plaintext.prototype.path = function() {
      return "M 0 0";
    };

    return Plaintext;

  })(Element);

  E.Diamond = (function(_super) {
    __extends(Diamond, _super);

    function Diamond() {
      return Diamond.__super__.constructor.apply(this, arguments);
    }

    return Diamond;

  })(Lozenge);

  E.Trapezium = (function(_super) {
    __extends(Trapezium, _super);

    function Trapezium() {
      return Trapezium.__super__.constructor.apply(this, arguments);
    }

    return Trapezium;

  })(Trapezium);

  E.Parallelogram = (function(_super) {
    __extends(Parallelogram, _super);

    function Parallelogram() {
      return Parallelogram.__super__.constructor.apply(this, arguments);
    }

    return Parallelogram;

  })(Parallelogram);

  E.House = (function(_super) {
    __extends(House, _super);

    function House() {
      return House.__super__.constructor.apply(this, arguments);
    }

    return House;

  })(House);

  E.Pentagon = (function(_super) {
    __extends(Pentagon, _super);

    function Pentagon() {
      return Pentagon.__super__.constructor.apply(this, arguments);
    }

    return Pentagon;

  })(Pentagon);

  E.Hexagon = (function(_super) {
    __extends(Hexagon, _super);

    function Hexagon() {
      return Hexagon.__super__.constructor.apply(this, arguments);
    }

    return Hexagon;

  })(Hexagon);

  E.Septagon = (function(_super) {
    __extends(Septagon, _super);

    function Septagon() {
      return Septagon.__super__.constructor.apply(this, arguments);
    }

    return Septagon;

  })(Septagon);

  E.Octogon = (function(_super) {
    __extends(Octogon, _super);

    function Octogon() {
      return Octogon.__super__.constructor.apply(this, arguments);
    }

    return Octogon;

  })(Octogon);

  E.Rect = (function(_super) {
    __extends(Rect, _super);

    function Rect() {
      return Rect.__super__.constructor.apply(this, arguments);
    }

    Rect.alias = true;

    return Rect;

  })(E.Box);

  E.Rectangle = (function(_super) {
    __extends(Rectangle, _super);

    function Rectangle() {
      return Rectangle.__super__.constructor.apply(this, arguments);
    }

    Rectangle.alias = true;

    return Rectangle;

  })(E.Box);

  E.Square = (function(_super) {
    __extends(Square, _super);

    function Square() {
      return Square.__super__.constructor.apply(this, arguments);
    }

    Square.prototype.txt_height = function() {
      return Math.max(Square.__super__.txt_height.call(this), this["super"]('txt_width'));
    };

    Square.prototype.txt_width = function() {
      return Math.max(Square.__super__.txt_width.call(this), this["super"]('txt_height'));
    };

    return Square;

  })(E.Box);

  E.Star = (function(_super) {
    __extends(Star, _super);

    function Star() {
      return Star.__super__.constructor.apply(this, arguments);
    }

    return Star;

  })(Star);

  E.None = (function(_super) {
    __extends(None, _super);

    function None() {
      return None.__super__.constructor.apply(this, arguments);
    }

    None.alias = true;

    return None;

  })(E.Plaintext);

  E.Underline = (function(_super) {
    __extends(Underline, _super);

    function Underline() {
      return Underline.__super__.constructor.apply(this, arguments);
    }

    Underline.prototype.path = function() {
      var h2, w2;
      w2 = this.width() / 2;
      h2 = this.height() / 2;
      return "M " + (-w2) + " " + h2 + " L " + w2 + " " + h2;
    };

    return Underline;

  })(Element);

  E.Note = (function(_super) {
    __extends(Note, _super);

    function Note() {
      return Note.__super__.constructor.apply(this, arguments);
    }

    return Note;

  })(Note);

  L.Link = (function(_super) {
    __extends(Link, _super);

    function Link() {
      return Link.__super__.constructor.apply(this, arguments);
    }

    return Link;

  })(Link);

  Diagrams.UseCase = (function(_super) {
    __extends(UseCase, _super);

    UseCase.prototype.label = 'UML Use Case Diagram';

    UseCase.prototype.types = UseCase.init_types();

    function UseCase() {
      UseCase.__super__.constructor.apply(this, arguments);
      this.linkstyle = new LinkStyles.Diagonal();
    }

    return UseCase;

  })(Diagram);

  Diagrams.UseCase.prototype.types.elements.Case = (function(_super) {
    __extends(Case, _super);

    function Case() {
      return Case.__super__.constructor.apply(this, arguments);
    }

    return Case;

  })(Ellipsis);

  Diagrams.UseCase.prototype.types.elements.Actor = (function(_super) {
    __extends(Actor, _super);

    function Actor() {
      Actor.__super__.constructor.apply(this, arguments);
      this.anchors[cardinal.E] = (function(_this) {
        return function() {
          return {
            x: _this.x + (_this.width() - _this["super"]('txt_width')) / 2,
            y: _this.y
          };
        };
      })(this);
      this.anchors[cardinal.W] = (function(_this) {
        return function() {
          return {
            x: _this.x - (_this.width() - _this["super"]('txt_width')) / 2,
            y: _this.y
          };
        };
      })(this);
    }

    Actor.prototype.txt_y = function() {
      return this.height() / 2 - this["super"]('txt_height') + 2 + 4 * this.margin.y;
    };

    Actor.prototype.txt_height = function() {
      return Actor.__super__.txt_height.call(this) + 50;
    };

    Actor.prototype.txt_width = function() {
      return Actor.__super__.txt_width.call(this) + 25;
    };

    Actor.prototype.path = function() {
      var bottom, hstick, wstick;
      wstick = (this.width() - this["super"]('txt_width')) / 2;
      hstick = (this.height() - this["super"]('txt_height')) / 4;
      bottom = this.txt_y() - 4 * this.margin.y;
      return "M " + (-wstick) + " " + bottom + " L 0 " + (bottom - hstick) + " M " + wstick + " " + bottom + " L 0 " + (bottom - hstick) + " M 0 " + (bottom - hstick) + " L 0 " + (bottom - 2 * hstick) + " M " + (-wstick) + " " + (bottom - 1.75 * hstick) + " L " + wstick + " " + (bottom - 2.25 * hstick) + " M 0 " + (bottom - 2 * hstick) + " L 0 " + (bottom - 3 * hstick) + " A " + (.5 * wstick) + " " + (.5 * hstick) + " 0 1 1 0 " + (bottom - 4 * hstick) + " A " + (.5 * wstick) + " " + (.5 * hstick) + " 0 1 1 0 " + (bottom - 3 * hstick);
    };

    return Actor;

  })(Element);

  Diagrams.UseCase.prototype.types.elements.System = (function(_super) {
    __extends(System, _super);

    function System() {
      return System.__super__.constructor.apply(this, arguments);
    }

    return System;

  })(Group);

  Diagrams.UseCase.prototype.types.links.Association = (function(_super) {
    __extends(Association, _super);

    function Association() {
      return Association.__super__.constructor.apply(this, arguments);
    }

    return Association;

  })(Association);

  Diagrams.UseCase.prototype.types.links.Inheritance = (function(_super) {
    __extends(Inheritance, _super);

    function Inheritance() {
      return Inheritance.__super__.constructor.apply(this, arguments);
    }

    return Inheritance;

  })(Inheritance);

  Diagrams.UseCase.prototype.types.links.Aggregation = (function(_super) {
    __extends(Aggregation, _super);

    function Aggregation() {
      return Aggregation.__super__.constructor.apply(this, arguments);
    }

    return Aggregation;

  })(Aggregation);

  Diagrams.UseCase.prototype.types.links.Composition = (function(_super) {
    __extends(Composition, _super);

    function Composition() {
      return Composition.__super__.constructor.apply(this, arguments);
    }

    return Composition;

  })(Composition);

  Diagrams.UseCase.prototype.types.links.Comment = (function(_super) {
    __extends(Comment, _super);

    function Comment() {
      return Comment.__super__.constructor.apply(this, arguments);
    }

    return Comment;

  })(Comment);

  Diagrams.Electric = (function(_super) {
    __extends(Electric, _super);

    Electric.prototype.label = 'Electric Diagram';

    Electric.prototype.types = Electric.init_types();

    function Electric() {
      Electric.__super__.constructor.apply(this, arguments);
      this.linkstyle = new LinkStyles.Rectangular();
      this.snap.a = 90;
    }

    return Electric;

  })(Diagram);

  E = Diagrams.Electric.prototype.types.elements;

  Electric = (function(_super) {
    __extends(Electric, _super);

    function Electric() {
      return Electric.__super__.constructor.apply(this, arguments);
    }

    Electric.resizeable = false;

    Electric.rotationable = true;

    Electric.prototype.anchor_list = function() {
      return attach_self([cardinal.W, cardinal.E], this);
    };

    Electric.prototype.base_height = function() {
      return 20;
    };

    Electric.prototype._base_width = function() {
      return 20;
    };

    Electric.prototype.base_width = function() {
      return this._base_width() + 2 * this.wire_margin();
    };

    Electric.prototype.wire_margin = function() {
      return 10;
    };

    Electric.prototype.txt_y = function() {
      return this.height() / 2 + 3 * this.margin.y;
    };

    Electric.prototype.txt_height = function() {
      return this.base_height();
    };

    Electric.prototype.txt_width = function() {
      return this.base_width();
    };

    return Electric;

  })(Element);

  E.Junction = (function(_super) {
    __extends(Junction, _super);

    Junction.fill = 'fg';

    function Junction() {
      Junction.__super__.constructor.apply(this, arguments);
      this.margin.x = 0;
      this.margin.y = 0;
      this.text = '';
    }

    Junction.prototype.base_width = function() {
      return this._base_width() / 4;
    };

    Junction.prototype.base_height = function() {
      return Junction.__super__.base_height.call(this) / 4;
    };

    Junction.prototype.anchor_list = function() {
      return attach_self([cardinal.N, cardinal.S, cardinal.W, cardinal.E], this);
    };

    Junction.prototype.path = function() {
      var h2, w2;
      w2 = this.width() / 2;
      h2 = this.height() / 2;
      return "M 0 " + (-h2) + " A " + w2 + " " + h2 + " 0 0 1 0 " + h2 + " A " + w2 + " " + h2 + " 0 0 1 0 " + (-h2);
    };

    return Junction;

  })(Electric);

  E.Resistor = (function(_super) {
    __extends(Resistor, _super);

    function Resistor() {
      return Resistor.__super__.constructor.apply(this, arguments);
    }

    Resistor.fill = 'none';

    Resistor.prototype._base_width = function() {
      return Resistor.__super__._base_width.call(this) * 3;
    };

    Resistor.prototype.path = function() {
      var h2, lw2, path, w, w2, _i;
      w2 = this.width() / 2;
      h2 = this.height() / 2;
      lw2 = w2 - this.wire_margin();
      path = "M " + (-w2) + " 0 L " + (-lw2) + " 0";
      for (w = _i = -3; _i <= 2; w = ++_i) {
        path = "" + path + " L " + (lw2 * w / 3 + lw2 / 6) + " " + (h2 * (w % 2 ? -1 : 1));
      }
      return "" + path + " L " + lw2 + " 0 L " + w2 + " 0";
    };

    return Resistor;

  })(Electric);

  E.Diode = (function(_super) {
    __extends(Diode, _super);

    function Diode() {
      return Diode.__super__.constructor.apply(this, arguments);
    }

    Diode.prototype.path = function() {
      var h2, lw2, w2;
      w2 = this.width() / 2;
      h2 = this.height() / 2;
      lw2 = w2 - this.wire_margin();
      return "M " + (-w2) + " 0 L " + (-lw2) + " 0 M " + (-lw2) + " " + (-h2) + " L " + lw2 + " 0 L " + lw2 + " " + (-h2) + " L " + lw2 + " " + h2 + " L " + lw2 + " 0 L " + (-lw2) + " " + h2 + " z M " + lw2 + " 0 L " + w2 + " 0";
    };

    return Diode;

  })(Electric);

  E.Battery = (function(_super) {
    __extends(Battery, _super);

    function Battery() {
      return Battery.__super__.constructor.apply(this, arguments);
    }

    Battery.fill = 'fg';

    Battery.prototype._base_width = function() {
      return Battery.__super__._base_width.call(this) / 3;
    };

    Battery.prototype.base_height = function() {
      return Battery.__super__.base_height.call(this) * 2;
    };

    Battery.prototype.path = function() {
      var h2, h4, lw2, lw4, w2;
      w2 = this.width() / 2;
      lw2 = w2 - this.wire_margin();
      lw4 = lw2 / 2;
      h2 = this.height() / 2;
      h4 = h2 / 2;
      return "M " + (-w2) + " 0 L " + (-lw2) + " 0 M " + (-lw2) + " " + (-h4) + " L " + (-lw4) + " " + (-h4) + " L " + (-lw4) + " " + h4 + " L " + (-lw2) + " " + h4 + " z M " + lw2 + " " + (-h2) + " L " + lw2 + " " + h2 + " M " + lw2 + " 0 L " + w2 + " 0";
    };

    return Battery;

  })(Electric);

  Transistor = (function(_super) {
    __extends(Transistor, _super);

    function Transistor() {
      Transistor.__super__.constructor.apply(this, arguments);
      this.anchors[cardinal.N] = (function(_this) {
        return function() {
          return {
            x: _this.x + (_this.width() / 2 - _this.wire_margin()) * .6,
            y: _this.y - _this.height() / 2
          };
        };
      })(this);
      this.anchors[cardinal.S] = (function(_this) {
        return function() {
          return {
            x: _this.x + (_this.width() / 2 - _this.wire_margin()) * .6,
            y: _this.y + _this.height() / 2
          };
        };
      })(this);
    }

    Transistor.prototype.base_width = function() {
      return 2 * this._base_width() + 2 * this.wire_margin();
    };

    Transistor.prototype.base_height = function() {
      return 2 * Transistor.__super__.base_height.call(this) + 2 * this.wire_margin();
    };

    Transistor.prototype.anchor_list = function() {
      return attach_self([cardinal.W, cardinal.N, cardinal.S], this);
    };

    Transistor.prototype.wire_margin = function() {
      return Transistor.__super__.wire_margin.call(this);
    };

    Transistor.prototype.path = function() {
      var h2, hI, hv, hw, lh2, lw2, w2, wI, ww;
      w2 = this.width() / 2;
      h2 = this.height() / 2;
      lw2 = w2 - this.wire_margin();
      lh2 = h2 - this.wire_margin();
      wI = lw2 / 4;
      hI = lh2 * .6;
      hv = hI / 2;
      ww = lw2 * .6;
      hw = lh2 * .8;
      return "M " + (-w2) + " 0 L " + (-lw2) + " 0 A " + lw2 + " " + lw2 + " 0 1 1 " + lw2 + " 0 A " + lw2 + " " + lw2 + " 0 1 1 " + (-lw2) + " 0 L " + (-wI) + " 0 M " + (-wI) + " " + (-hI) + " L " + (-wI) + " " + hI + " M " + (-wI) + " " + (-hv) + " L " + ww + " " + (-hw) + " M " + ww + " " + (-hw) + " L " + ww + " " + (-h2) + " M " + (-wI) + " " + hv + " L " + ww + " " + hw + " L " + ww + " " + h2;
    };

    return Transistor;

  })(Electric);

  E.PNPTransistor = (function(_super) {
    __extends(PNPTransistor, _super);

    function PNPTransistor() {
      return PNPTransistor.__super__.constructor.apply(this, arguments);
    }

    PNPTransistor.prototype.path = function() {
      var h2, ha, hb, hw, lh2, lw2, w2, wa, wb, ww;
      w2 = this.width() / 2;
      h2 = this.height() / 2;
      lw2 = w2 - this.wire_margin();
      lh2 = h2 - this.wire_margin();
      ww = lw2 * .6;
      hw = lh2 * .8;
      wa = lw2 * .1;
      ha = lh2 * .7;
      wb = lw2 * .3;
      hb = lh2 * .4;
      return "" + (PNPTransistor.__super__.path.call(this)) + " M " + ww + " " + (-hw) + " L " + wa + " " + (-ha) + " M " + ww + " " + (-hw) + " L " + wb + " " + (-hb);
    };

    return PNPTransistor;

  })(Transistor);

  E.NPNTransistor = (function(_super) {
    __extends(NPNTransistor, _super);

    function NPNTransistor() {
      return NPNTransistor.__super__.constructor.apply(this, arguments);
    }

    NPNTransistor.prototype.path = function() {
      var h2, ha, hb, hw, lh2, lw2, w2, wa, wb, ww;
      w2 = this.width() / 2;
      h2 = this.height() / 2;
      lw2 = w2 - this.wire_margin();
      lh2 = h2 - this.wire_margin();
      ww = lw2 * .6;
      hw = lh2 * .8;
      wa = lw2 * .1;
      ha = lh2 * .7;
      wb = lw2 * .3;
      hb = lh2 * .4;
      return "" + (NPNTransistor.__super__.path.call(this)) + " M " + ww + " " + hw + " L " + wa + " " + ha + " M " + ww + " " + hw + " L " + wb + " " + hb;
    };

    return NPNTransistor;

  })(Transistor);

  Diagrams.Electric.prototype.types.links.Wire = (function(_super) {
    __extends(Wire, _super);

    function Wire() {
      return Wire.__super__.constructor.apply(this, arguments);
    }

    return Wire;

  })(Link);

  Diagrams.Class = (function(_super) {
    __extends(Class, _super);

    Class.prototype.label = 'UML Class Diagram';

    Class.prototype.types = Class.init_types();

    function Class() {
      Class.__super__.constructor.apply(this, arguments);
      this.linkstyle = new LinkStyles.Diagonal();
    }

    return Class;

  })(Diagram);

  Diagrams.Class.prototype.types.elements.Note = (function(_super) {
    __extends(Note, _super);

    function Note() {
      return Note.__super__.constructor.apply(this, arguments);
    }

    return Note;

  })(Note);

  Diagrams.Class.prototype.types.elements.Class = (function(_super) {
    __extends(Class, _super);

    function Class() {
      return Class.__super__.constructor.apply(this, arguments);
    }

    Class.prototype.shift = 10;

    Class.prototype.height = function() {
      return Class.__super__.height.call(this) + this.shift * 2;
    };

    Class.prototype.txt_y = function() {
      return Class.__super__.txt_y.call(this) - this.shift;
    };

    Class.prototype.path = function() {
      var h2, w2;
      w2 = this.width() / 2;
      h2 = this.height() / 2;
      return "" + (Class.__super__.path.call(this)) + " M " + (-w2) + " " + (h2 - this.shift) + " L " + w2 + " " + (h2 - this.shift) + " M " + (-w2) + " " + (h2 - 2 * this.shift) + " L " + w2 + " " + (h2 - 2 * this.shift);
    };

    return Class;

  })(Rect);

  Diagrams.Class.prototype.types.elements.System = (function(_super) {
    __extends(System, _super);

    function System() {
      return System.__super__.constructor.apply(this, arguments);
    }

    return System;

  })(Group);

  L = Diagrams.Class.prototype.types.links;

  L.Association = (function(_super) {
    __extends(Association, _super);

    function Association() {
      return Association.__super__.constructor.apply(this, arguments);
    }

    return Association;

  })(Association);

  L.Inheritance = (function(_super) {
    __extends(Inheritance, _super);

    function Inheritance() {
      return Inheritance.__super__.constructor.apply(this, arguments);
    }

    return Inheritance;

  })(Inheritance);

  L.Aggregation = (function(_super) {
    __extends(Aggregation, _super);

    function Aggregation() {
      return Aggregation.__super__.constructor.apply(this, arguments);
    }

    return Aggregation;

  })(Aggregation);

  L.Composition = (function(_super) {
    __extends(Composition, _super);

    function Composition() {
      return Composition.__super__.constructor.apply(this, arguments);
    }

    return Composition;

  })(Composition);

  L.Comment = (function(_super) {
    __extends(Comment, _super);

    function Comment() {
      return Comment.__super__.constructor.apply(this, arguments);
    }

    return Comment;

  })(Comment);

  order = function(a, b) {
    return d3.ascending(a.ts, b.ts);
  };

  node_add = function(type, x, y) {
    var cls, new_node, nth;
    cls = diagram.types.elements[type];
    diagram.last_types.element = cls;
    nth = diagram.elements.filter(function(node) {
      return node instanceof cls;
    }).length + 1;
    new_node = new cls(x, y, "" + type + " #" + nth, !diagram.force);
    diagram.elements.push(new_node);
    if (d3.event) {
      diagram.selection = [new_node];
    }
    return svg.sync(true);
  };

  remove = function(nodes) {
    var lnk, node, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = nodes.length; _i < _len; _i++) {
      node = nodes[_i];
      if (__indexOf.call(diagram.elements, node) >= 0) {
        diagram.elements.splice(diagram.elements.indexOf(node), 1);
      } else if (__indexOf.call(diagram.links, node) >= 0) {
        diagram.links.splice(diagram.links.indexOf(node), 1);
      }
      _results.push((function() {
        var _j, _len1, _ref, _results1;
        _ref = diagram.links.slice();
        _results1 = [];
        for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
          lnk = _ref[_j];
          if (node === lnk.source || node === lnk.target) {
            _results1.push(diagram.links.splice(diagram.links.indexOf(lnk), 1));
          } else {
            _results1.push(void 0);
          }
        }
        return _results1;
      })());
    }
    return _results;
  };

  clip = {
    elements: [],
    links: []
  };

  cut = function() {
    copy();
    remove(diagram.selection);
    diagram.selection = [];
    svg.sync(true);
    return false;
  };

  copy = function() {
    var elts, node, _i, _j, _len, _len1, _ref, _ref1, _ref2, _ref3;
    clip.elements = [];
    clip.links = [];
    elts = [];
    _ref = diagram.selection;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      node = _ref[_i];
      if (__indexOf.call(diagram.elements, node) >= 0) {
        clip.elements.push(node.objectify());
        elts.push(node);
      }
    }
    _ref1 = diagram.selection;
    for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
      node = _ref1[_j];
      if (__indexOf.call(diagram.links, node) >= 0) {
        if ((_ref2 = node.source, __indexOf.call(diagram.selection, _ref2) >= 0) && (_ref3 = node.target, __indexOf.call(diagram.selection, _ref3) >= 0)) {
          clip.links.push(node.objectify(elts));
        }
      }
    }
    return false;
  };

  paste = function() {
    var elt, elts, link, node, shift, _i, _j, _len, _len1, _ref, _ref1;
    elts = [];
    diagram.selection = [];
    if (!diagram.force) {
      shift = {
        x: Math.round(50 * (Math.random() * 2 - 1)),
        y: Math.round(50 * (Math.random() * 2 - 1))
      };
    } else {
      shift = {
        x: 0,
        y: 0
      };
    }
    _ref = clip.elements;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      node = _ref[_i];
      elt = diagram.elementify(node);
      elt.x += shift.x;
      elt.y += shift.y;
      diagram.elements.push(elt);
      elts.push(elt);
      diagram.selection.push(elt);
    }
    _ref1 = clip.links;
    for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
      node = _ref1[_j];
      link = diagram.linkify(node, elts);
      diagram.links.push(link);
      diagram.selection.push(link);
    }
    svg.sync(true);
    return false;
  };

  last_command = {
    fun: null,
    args: null
  };

  wrap = function(fun) {
    return function() {
      if ($('#overlay').hasClass('visible')) {
        if (arguments[1] === 'esc') {
          $('#overlay').click();
        }
        return;
      }
      last_command = {
        fun: fun,
        args: arguments
      };
      return fun.apply(this, arguments);
    };
  };

  commands = {
    undo: {
      fun: function(e) {
        history.go(-1);
        return e != null ? e.preventDefault() : void 0;
      },
      label: 'Undo',
      glyph: 'chevron-left',
      hotkey: 'ctrl+z'
    },
    redo: {
      fun: function(e) {
        history.go(1);
        return e != null ? e.preventDefault() : void 0;
      },
      label: 'Redo',
      glyph: 'chevron-right',
      hotkey: 'ctrl+y'
    },
    save: {
      fun: function(e) {
        svg.sync(true);
        save();
        return e != null ? e.preventDefault() : void 0;
      },
      label: 'Save locally',
      glyph: 'save',
      hotkey: 'ctrl+s'
    },
    "export": {
      fun: function(e) {
        var $a, svgout;
        svgout = diagram.to_svg();
        $('body').append($a = $('<a>', {
          href: URL.createObjectURL(new Blob([svgout], {
            type: 'image/svg+xml'
          })),
          download: "" + diagram.title + ".svg"
        }));
        $a[0].click();
        return $a.remove();
      },
      label: 'Export to svg',
      glyph: 'export',
      hotkey: 'ctrl+enter'
    },
    export_to_textile: {
      fun: function(e) {
        return edit((function() {
          return "!data:image/svg+xml;base64," + (btoa(diagram.to_svg())) + "!:http://kozea.github.io/umlaut/" + location.hash;
        }), (function() {
          return null;
        }));
      },
      hotkey: 'ctrl+b'
    },
    export_to_markdown: {
      fun: function(e) {
        edit((function() {
          return "[![" + diagram.title + "][" + diagram.title + " - base64]][" + diagram.title + " - umlaut_url]\n\n[" + diagram.title + " - base64]: data:image/svg+xml;base64," + (btoa(diagram.to_svg())) + "\n[" + diagram.title + " - umlaut_url]: http://kozea.github.io/umlaut/" + location.hash;
        }), (function() {
          return null;
        }));
        return e.preventDefault();
      },
      hotkey: 'ctrl+m ctrl+d'
    },
    edit: {
      fun: function() {
        return edit((function() {
          var e, _ref, _ref1;
          if (diagram.selection.length === 1) {
            e = diagram.selection[0];
            return [e.text, (_ref = e.attrs) != null ? _ref.color : void 0, (_ref1 = e.attrs) != null ? _ref1.fillcolor : void 0];
          } else {
            return ['', '#ffffff', '#000000'];
          }
        }), (function(txt) {
          var node, _i, _len, _ref, _results;
          _ref = diagram.selection;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            node = _ref[_i];
            _results.push(node.text = txt);
          }
          return _results;
        }));
      },
      label: 'Edit elements text',
      glyph: 'edit',
      hotkey: 'e'
    },
    remove: {
      fun: function() {
        remove(diagram.selection);
        diagram.selection = [];
        return svg.sync(true);
      },
      label: 'Remove elements',
      glyph: 'remove-sign',
      hotkey: 'del'
    },
    select_all: {
      fun: function(e) {
        diagram.selection = diagram.elements.concat(diagram.links);
        svg.tick();
        return e != null ? e.preventDefault() : void 0;
      },
      label: 'Select all elements',
      glyph: 'fullscreen',
      hotkey: 'ctrl+a'
    },
    force: {
      fun: function(e) {
        if (diagram.force) {
          diagram.force.stop();
          diagram.force = null;
          return;
        }
        diagram.start_force();
        return e != null ? e.preventDefault() : void 0;
      },
      label: 'Toggle force',
      glyph: 'send',
      hotkey: 'tab'
    },
    linkstyle: {
      fun: function() {
        diagram.linkstyle = new LinkStyles[next(LinkStyles, diagram.linkstyle.cls.name)]();
        return svg.tick();
      },
      label: 'Change link style',
      glyph: 'retweet',
      hotkey: 'space'
    },
    defaultscale: {
      fun: function() {
        diagram.zoom.scale = 1;
        diagram.zoom.translate = [0, 0];
        return svg.sync(true);
      },
      label: 'Reset view',
      glyph: 'screenshot',
      hotkey: 'ctrl+backspace'
    },
    snaptogrid: {
      fun: function() {
        var node, _i, _len, _ref;
        _ref = diagram.elements;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          node = _ref[_i];
          node.x = node.px = diagram.snap.x * Math.floor(node.x / diagram.snap.x);
          node.y = node.py = diagram.snap.y * Math.floor(node.y / diagram.snap.y);
        }
        return svg.tick();
      },
      label: 'Snap to grid',
      glyph: 'magnet',
      hotkey: 'ctrl+space'
    },
    "switch": {
      fun: function() {
        var link, node, _i, _j, _len, _len1, _ref, _ref1, _ref2, _ref3;
        _ref = diagram.selection;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          node = _ref[_i];
          if (node instanceof Link) {
            _ref1 = [node.target, node.source], node.source = _ref1[0], node.target = _ref1[1];
          }
          if (node instanceof Element) {
            _ref2 = diagram.links;
            for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
              link = _ref2[_j];
              _ref3 = [link.target, link.source], link.source = _ref3[0], link.target = _ref3[1];
            }
          }
        }
        return svg.tick();
      },
      label: 'Switch link direction',
      glyph: 'transfer',
      hotkey: 'w'
    },
    cycle_start_marker: {
      fun: function() {
        var link, node, _i, _j, _len, _len1, _ref, _ref1;
        _ref = diagram.selection;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          node = _ref[_i];
          if (node instanceof Link) {
            Markers._cycle(node, true);
          }
          if (node instanceof Element) {
            _ref1 = diagram.links;
            for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
              link = _ref1[_j];
              Markers._cycle(link, true);
            }
          }
        }
        return svg.sync(true);
      },
      label: 'Cycle start marker',
      glyph: 'arrow-right',
      hotkey: 'm s'
    },
    cycle_end_marker: {
      fun: function() {
        var link, node, _i, _j, _len, _len1, _ref, _ref1;
        _ref = diagram.selection;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          node = _ref[_i];
          if (node instanceof Link) {
            Markers._cycle(node);
          }
          if (node instanceof Element) {
            _ref1 = diagram.links;
            for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
              link = _ref1[_j];
              Markers._cycle(link);
            }
          }
        }
        return svg.sync(true);
      },
      label: 'Cycle end marker',
      glyph: 'arrow-left',
      hotkey: 'm e'
    },
    back_to_list: {
      fun: function(e) {
        if (diagram.force) {
          diagram.force.stop();
        }
        if (diagram instanceof Diagrams.Dot) {
          $('textarea.dot').val(diagram.to_dot());
        }
        return location.href = '#';
      },
      label: 'Go back to diagram list',
      glyph: 'list',
      hotkey: 'esc'
    },
    cut: {
      fun: cut,
      hotkey: 'ctrl+x'
    },
    copy: {
      fun: copy,
      hotkey: 'ctrl+c'
    },
    paste: {
      fun: paste,
      hotkey: 'ctrl+v'
    }
  };

  $(function() {
    var button, command, name;
    for (name in commands) {
      command = commands[name];
      if (command.glyph) {
        button = d3.select('.btns').append('button').attr('title', "" + command.label + " [" + command.hotkey + "]").attr('class', 'btn btn-default btn-sm').on('click', command.fun).append('span').attr('class', "glyphicon glyphicon-" + command.glyph);
      }
      Mousetrap.bind(command.hotkey, wrap(command.fun));
    }
    Mousetrap.bind('z', function() {
      return last_command.fun.apply(this, last_command.args);
    });
    $(window).on('cut', cut).on('copy', copy).on('paste', paste);
    return $('.waterlogo').on('wheel', function(e) {
      if (e.originalEvent.deltaY > 0) {
        return history.go(-1);
      } else {
        return history.go(1);
      }
    });
  });

  init_commands = function() {
    var cls, conf, e1, e2, element, first, fun, hotkey, i, icon, inc, key, link, margin, name, svgicon, taken_hotkeys, val, way, _ref, _ref1, _ref2, _ref3, _results;
    _ref = diagram.force_conf;
    for (conf in _ref) {
      val = _ref[conf];
      _ref1 = {
        increase: 1.1,
        decrease: 0.9
      };
      for (way in _ref1) {
        inc = _ref1[way];
        Mousetrap.bind("f " + conf[0] + " " + (way === 'increase' ? '+' : '-'), (function(c, i) {
          return wrap(function(e) {
            if (diagram.force) {
              diagram.force_conf[c] *= i;
              diagram.force.stop();
            }
            return diagram.start_force();
          });
        })(conf, inc));
      }
    }
    taken_hotkeys = [];
    $('aside .icons .specific').each(function() {
      return Mousetrap.unbind($(this).attr('data-hotkey'));
    });
    $('aside .icons svg').remove();
    $('aside h3').attr('id', diagram.cls.name).addClass('specific').text(diagram.label);
    _ref2 = diagram.types.elements;
    for (name in _ref2) {
      cls = _ref2[name];
      if (cls.alias) {
        continue;
      }
      i = 1;
      key = name[0].toLowerCase();
      while (i < name.length && __indexOf.call(taken_hotkeys, key) >= 0) {
        key = name[i++].toLowerCase();
      }
      taken_hotkeys.push(key);
      fun = (function(node) {
        return function() {
          return node_add(node);
        };
      })(cls);
      hotkey = "a " + key;
      icon = new cls(0, 0, name);
      svgicon = d3.select('aside .icons').append('svg').attr('class', 'icon specific draggable btn btn-default').attr('title', "" + name + " [" + hotkey + "]").attr('data-hotkey', hotkey).attr('data-type', name).call(extern_drag);
      element = svgicon.selectAll('g.element').data([icon]);
      element.enter().call(enter_node, false);
      element.call(update_node);
      margin = 3;
      svgicon.attr('viewBox', "" + (-icon.width() / 2 - margin) + " " + (-icon.height() / 2 - margin) + " " + (icon.width() + 2 * margin) + " " + (icon.height() + 2 * margin)).attr('width', icon.width()).attr('height', icon.height()).attr('preserveAspectRatio', 'xMidYMid meet');
      Mousetrap.bind(hotkey, wrap(fun));
    }
    taken_hotkeys = [];
    first = true;
    _ref3 = diagram.types.links;
    _results = [];
    for (name in _ref3) {
      cls = _ref3[name];
      i = 1;
      key = name[0].toLowerCase();
      while (i < name.length && __indexOf.call(taken_hotkeys, key) >= 0) {
        key = name[i++].toLowerCase();
      }
      taken_hotkeys.push(key);
      hotkey = "l " + key;
      icon = new cls(e1 = new Element(0, 0), e2 = new Element(100, 0));
      e1.set_txt_bbox({
        width: 10,
        height: 10
      });
      e2.set_txt_bbox({
        width: 10,
        height: 10
      });
      fun = function(lnk) {
        return function() {
          diagram.last_types.link = lnk;
          d3.selectAll('aside .icons .link').classed('active', false);
          return d3.select(this).classed('active', true);
        };
      };
      svgicon = d3.select('aside .icons').append('svg').attr('class', "icon specific btn btn-default link " + name).attr('title', "" + name + " [" + hotkey + "]").attr('data-hotkey', hotkey).classed('active', first).on('click', fun(cls));
      link = svgicon.selectAll('g.link').data([icon]);
      link.enter().call(enter_link, false);
      link.call(update_link);
      link.call(tick_link);
      svgicon.attr('height', 20).attr('viewBox', "0 -10 100 20");
      Mousetrap.bind(hotkey, wrap(fun));
      if (first) {
        diagram.last_types.link = cls;
        _results.push(first = false);
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  edit = function(getter, setter, color) {
    var $overlay, $textarea, bg, close, fg, text, _ref;
    if (color == null) {
      color = true;
    }
    $overlay = $('#overlay').addClass('visible');
    $textarea = $overlay.find('textarea');
    $textarea.on('input', function() {
      var val;
      setter(((function() {
        var _i, _len, _ref, _results;
        _ref = this.value.split('\n');
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          val = _ref[_i];
          _results.push(val || ' ');
        }
        return _results;
      }).call(this)).join('\n'));
      return svg.sync();
    }).on('keydown', function(e) {
      if (e.keyCode === 27) {
        return $overlay.click();
      }
    });
    if (color) {
      $overlay.find('.with-color').show();
      _ref = getter(), text = _ref[0], fg = _ref[1], bg = _ref[2];
      $('.color-box.fg').css('background-color', fg || '#000000');
      $('.color-box.bg').css('background-color', bg || '#ffffff');
    } else {
      $overlay.find('.with-color').hide();
      text = getter();
    }
    $textarea.val(text).select().focus();
    close = function(e) {
      if (e.target === this) {
        $textarea.off('input');
        $textarea.off('keydown');
        $textarea.val('');
        $overlay.removeClass('visible');
        $('.color-box').colpickHide();
        return svg.sync(true);
      }
    };
    return $overlay.on('click', close).on('touchstart', close);
  };

  $(function() {
    return $('.color-box').colpick({
      layout: 'hex',
      submit: 0,
      onChange: function(hsb, hex, rgb, el) {
        var $el, fg, node, _i, _len, _ref;
        $el = $(el);
        $el.css('background-color', "#" + hex);
        fg = $el.hasClass('fg');
        _ref = diagram.selection;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          node = _ref[_i];
          if (!node.attrs) {
            node.attrs = {};
          }
          if (fg) {
            node.attrs.color = '#' + hex;
          } else {
            node.attrs.fillcolor = '#' + hex;
          }
        }
        return svg.sync();
      }
    });
  });

  svg_selection_drag = d3.behavior.drag().on("dragstart.selection", function() {
    if (!d3.event.sourceEvent.shiftKey) {
      diagram.selection = [];
      if (diagram.linking.length) {
        diagram.linking = [];
        svg.sync();
      }
      svg.tick();
    }
  }).on("drag.selection", function() {
    var move, rect, sel;
    if (!d3.event.sourceEvent.shiftKey) {
      return;
    }
    sel = svg.svg.select('rect.selection');
    if (sel.empty()) {
      sel = svg.svg.select('#bg').append("rect").attr({
        "class": "selection",
        x: d3.event.x,
        y: d3.event.y,
        width: 0,
        height: 0
      });
    }
    rect = {
      x: +sel.attr('x'),
      y: +sel.attr('y'),
      width: +sel.attr('width'),
      height: +sel.attr('height')
    };
    move = {
      x: d3.event.x - rect.x,
      y: d3.event.y - rect.y
    };
    if (move.x < 1 || (move.x * 2 < rect.width)) {
      rect.x = d3.event.x;
      rect.width -= move.x;
    } else {
      rect.width = move.x;
    }
    if (move.y < 1 || (move.y * 2 < rect.height)) {
      rect.y = d3.event.y;
      rect.height -= move.y;
    } else {
      rect.height = move.y;
    }
    rect.width = Math.max(0, rect.width);
    rect.height = Math.max(0, rect.height);
    sel.attr(rect);
    svg.svg.selectAll('g.element').each(function(elt) {
      var g, inside, link, selected, _i, _j, _len, _len1, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _results, _results1;
      g = d3.select(this);
      selected = __indexOf.call(diagram.selection, elt) >= 0;
      inside = elt["in"](rect);
      if (inside && !selected) {
        diagram.selection.push(elt);
        _ref = diagram.links;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          link = _ref[_i];
          if ((link.source === elt && (_ref1 = link.target, __indexOf.call(diagram.selection, _ref1) >= 0) && __indexOf.call(diagram.selection, link) < 0) || (link.target === elt && (_ref2 = link.source, __indexOf.call(diagram.selection, _ref2) >= 0) && __indexOf.call(diagram.selection, link) < 0)) {
            _results.push(diagram.selection.push(link));
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      } else if (!inside && selected) {
        diagram.selection.splice(diagram.selection.indexOf(elt), 1);
        _ref3 = diagram.links;
        _results1 = [];
        for (_j = 0, _len1 = _ref3.length; _j < _len1; _j++) {
          link = _ref3[_j];
          if ((link.source === elt && (_ref4 = link.target, __indexOf.call(diagram.selection, _ref4) < 0) && __indexOf.call(diagram.selection, link) >= 0) || (link.target === elt && (_ref5 = link.source, __indexOf.call(diagram.selection, _ref5) < 0) && __indexOf.call(diagram.selection, link) >= 0)) {
            _results1.push(diagram.selection.splice(diagram.selection.indexOf(link), 1));
          } else {
            _results1.push(void 0);
          }
        }
        return _results1;
      }
    });
    return svg.tick();
  }).on("dragend.selection", function() {
    var height, sel, width, x, y;
    sel = svg.svg.select("rect.selection");
    if (!sel.empty()) {
      x = +sel.attr("x");
      y = +sel.attr("y");
      width = +sel.attr("width");
      height = +sel.attr("height");
      svg.sync();
    }
    return svg.svg.selectAll("rect.selection").remove();
  });

  move_drag = d3.behavior.drag().origin(function(i) {
    return i;
  }).on('dragstart.move', function(node) {
    svg.svg.classed('dragging', true);
    svg.svg.classed('translating', true);
    if (__indexOf.call(diagram.selection, node) < 0) {
      if (d3.event.sourceEvent.shiftKey) {
        diagram.selection.push(node);
      } else {
        diagram.selection = [node];
      }
    }
    node.ts = timestamp();
    if (node instanceof Group) {
      node.ts *= -1;
    }
    svg.svg.selectAll('g.element').sort(order);
    svg.tick();
    return d3.event.sourceEvent.stopPropagation();
  }).on("drag.move", function(node) {
    var delta, nod, x, y, _i, _j, _len, _len1, _ref, _ref1, _ref2;
    x = diagram.force ? 'px' : 'x';
    y = diagram.force ? 'py' : 'y';
    if (_ref = !node, __indexOf.call(diagram.selection, _ref) >= 0) {
      diagram.selection.push(node);
    }
    _ref1 = diagram.selection;
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      nod = _ref1[_i];
      nod.fixed = true;
    }
    if (d3.event.sourceEvent.shiftKey) {
      delta = {
        x: node[x] - d3.event.x,
        y: node[y] - d3.event.y
      };
    } else {
      delta = {
        x: node[x] - diagram.snap.x * Math.floor(d3.event.x / diagram.snap.x),
        y: node[y] - diagram.snap.y * Math.floor(d3.event.y / diagram.snap.y)
      };
    }
    _ref2 = diagram.selection;
    for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
      nod = _ref2[_j];
      nod[x] -= delta.x;
      nod[y] -= delta.y;
    }
    if (diagram.force) {
      return diagram.force.resume();
    } else {
      return svg.tick();
    }
  }).on('dragend.move', function(node) {
    var index, lnk, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2;
    svg.svg.classed('dragging', false);
    svg.svg.classed('translating', false);
    _ref = diagram.elements;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      node = _ref[_i];
      node.fixed = false;
    }
    diagram.dragging = false;
    if (!$(d3.event.sourceEvent.target).closest('.inside').size()) {
      _ref1 = diagram.selection;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        node = _ref1[_j];
        if (__indexOf.call(diagram.elements, node) >= 0) {
          diagram.elements.splice(diagram.elements.indexOf(node), 1);
        }
        _ref2 = diagram.links.slice();
        for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
          lnk = _ref2[_k];
          if (node === lnk.source || node === lnk.target) {
            index = diagram.links.indexOf(lnk);
            if (index >= 0) {
              diagram.links.splice(index, 1);
            }
          }
        }
      }
      diagram.selection = [];
    }
    return svg.sync(true);
  });

  nsweo_resize_drag = d3.behavior.drag().on("dragstart.resize", function(handle) {
    var node;
    svg.svg.classed('dragging', true);
    svg.svg.classed('resizing', true);
    node = d3.select($(this).closest('.element').get(0)).data()[0];
    diagram._origin = mouse_xy(svg.svg.node());
    node.ox = node.x;
    node.oy = node.y;
    node.owidth = node.width();
    node.oheight = node.height();
    node.fixed = true;
    return d3.event.sourceEvent.stopPropagation();
  }).on("drag.resize", function(handle) {
    var angle, delta, m, node, nodes, shift, signs, x, y;
    nodes = d3.select($(this).closest('.element').get(0));
    node = nodes.data()[0];
    m = mouse_xy(svg.svg.node());
    if (handle === 'O') {
      delta = {
        x: m.x - node.x,
        y: m.y - node.y
      };
      angle = atan2(delta.y, delta.x) + pi / 2;
      if (!d3.event.sourceEvent.shiftKey) {
        angle = to_rad(diagram.snap.a * Math.floor(to_deg(angle) / diagram.snap.a));
      }
      node._rotation = angle;
    } else {
      delta = {
        x: m.x - diagram._origin.x,
        y: m.y - diagram._origin.y
      };
      delta = rotate(delta, 2 * pi - node._rotation);
      x = diagram.force ? 'px' : 'x';
      y = diagram.force ? 'py' : 'y';
      signs = cardinal_to_direction(handle);
      node.width(node.owidth + signs.x * delta.x);
      node.height(node.oheight + signs.y * delta.y);
      shift = {
        x: signs.x * (node.width() - node.owidth) / 2,
        y: signs.y * (node.height() - node.oheight) / 2
      };
      shift = rotate(shift, node._rotation);
      node[x] = node.ox + shift.x;
      node[y] = node.oy + shift.y;
      nodes.call(update_node);
    }
    return svg.tick();
  }).on("dragend.resize", function(handle) {
    var node;
    svg.svg.classed('dragging', false);
    svg.svg.classed('resizing', false);
    node = d3.select($(this).closest('.element').get(0)).data()[0];
    node.ox = node.oy = node.owidth = node.oheight = null;
    node.fixed = false;
    return svg.sync(true);
  });

  anchor_link_drag = d3.behavior.drag().on("dragstart.link", function(anchor) {
    svg.svg.classed('dragging', true);
    svg.svg.classed('linking', true);
    return d3.event.sourceEvent.stopPropagation();
  }).on("drag.link", function(anchor) {
    var $anchor, $node, evt, link, node, target, type;
    if (!diagram.linking.length) {
      node = d3.select($(this).closest('.element').get(0)).data()[0];
      type = diagram.last_types.link;
      link = new type(node, new Mouse(0, 0, ''));
      link.source_anchor = anchor;
      diagram.linking.push(link);
      svg.sync();
    }
    link = diagram.linking[0];
    evt = d3.event.sourceEvent;
    if (evt.type === 'touchmove') {
      target = document.elementFromPoint(evt.targetTouches[0].clientX, evt.targetTouches[0].clientY);
    } else {
      target = evt.target;
    }
    $anchor = $(target).closest('.anchor');
    if ($anchor.size()) {
      $node = $anchor.closest('.element');
    } else {
      $node = $(target).closest('.element');
    }
    if ($node.size()) {
      link.target = $node.get(0).__data__;
      if ($anchor.size()) {
        link.target_anchor = +$anchor.attr('data-anchor');
      } else {
        link.target_anchor = null;
      }
    } else {
      if (!(link.target instanceof Mouse)) {
        link.target = new Mouse(0, 0, '');
      }
      link.target.x = link.source.x + d3.event.x;
      link.target.y = link.source.y + d3.event.y;
    }
    return svg.tick();
  }).on("dragend.link", function(anchor) {
    var link;
    svg.svg.classed('dragging', false);
    svg.svg.classed('linking', false);
    if (diagram.linking.length) {
      link = diagram.linking[0];
      diagram.linking = [];
      if (link.target instanceof Mouse) {
        return svg.sync();
      } else {
        diagram.links.push(link);
        return svg.sync(true);
      }
    }
  });

  mouse_node = function(nodes) {
    return nodes.call(edit_it, function(node) {
      return edit((function() {
        var _ref, _ref1;
        return [node.text, (_ref = node.attrs) != null ? _ref.color : void 0, (_ref1 = node.attrs) != null ? _ref1.fillcolor : void 0];
      }), (function(txt) {
        return node.text = txt;
      }));
    });
  };

  mouse_link = function(link) {
    return link.call(edit_it, function(lnk) {
      var nearest;
      nearest = lnk.nearest(mouse_xy(svg.svg.node()));
      if (nearest === lnk.source) {
        return edit((function() {
          return [lnk.text.source, null, null];
        }), (function(txt) {
          return lnk.text.source = txt;
        }));
      } else {
        return edit((function() {
          return [lnk.text.target, null, null];
        }), (function(txt) {
          return lnk.text.target = txt;
        }));
      }
    });
  };

  link_drag = d3.behavior.drag().on("dragstart.link", function(link) {
    if (!d3.event.sourceEvent.shiftKey) {
      diagram.selection = [];
    }
    diagram.selection.push(link);
    svg.tick();
    svg.svg.classed('dragging', true);
    svg.svg.classed('linking', true);
    return d3.event.sourceEvent.stopPropagation();
  }).on("drag.link", function(link) {
    var $anchor, $node, evt, mouse, nearest, target;
    if (!diagram.linking.length) {
      diagram.links.splice(diagram.links.indexOf(link), 1);
      mouse = new Mouse(d3.event.x, d3.event.y, '');
      nearest = link.nearest(mouse);
      if (link.source === nearest) {
        link.source = link.target;
        link.source_anchor = link.target_anchor;
      }
      link.target = mouse;
      link.target_anchor = null;
      diagram.linking.push(link);
      svg.sync();
    }
    evt = d3.event.sourceEvent;
    if (evt.type === 'touchmove') {
      target = document.elementFromPoint(evt.targetTouches[0].clientX, evt.targetTouches[0].clientY);
    } else {
      target = evt.target;
    }
    link = diagram.linking[0];
    $anchor = $(target).closest('.anchor');
    if ($anchor.size()) {
      $node = $anchor.closest('.element');
    } else {
      $node = $(target).closest('.element');
    }
    if ($node.size()) {
      link.target = $node.get(0).__data__;
      if ($anchor.size()) {
        link.target_anchor = +$anchor.attr('data-anchor');
      } else {
        link.target_anchor = null;
      }
    } else {
      if (!(link.target instanceof Mouse)) {
        link.target = new Mouse(0, 0, '');
      }
      link.target.x = d3.event.x;
      link.target.y = d3.event.y;
    }
    return svg.tick();
  }).on("dragend.link", function(anchor) {
    var link;
    svg.svg.classed('dragging', false);
    svg.svg.classed('linking', false);
    if (diagram.linking.length) {
      link = diagram.linking[0];
      diagram.linking = [];
      if (link.target instanceof Mouse) {
        return svg.sync();
      } else {
        diagram.links.push(link);
        return svg.sync(true);
      }
    }
  });

  floating = null;

  extern_drag = d3.behavior.drag().on('dragstart.extern', function() {
    var $elt;
    if (floating) {
      return;
    }
    $elt = $(this);
    floating = {
      $elt: $(this.cloneNode(true)),
      offset: {
        top: $elt.parent().offset().top - $elt.outerHeight() / 2,
        left: $elt.parent().offset().left - $elt.outerWidth() / 2
      }
    };
    $('body').append(floating.$elt.css({
      position: 'fixed'
    }));
    return d3.event.sourceEvent.stopPropagation();
  }).on("drag.extern", function() {
    return floating.$elt.css({
      top: floating.offset.top + d3.event.y,
      left: floating.offset.left + d3.event.x
    });
  }).on('dragend.extern', function() {
    var type, x, y;
    if (!floating) {
      return;
    }
    x = floating.$elt.offset().left - $('#diagram').offset().left + floating.$elt.outerWidth() / 2;
    y = floating.$elt.offset().top - $('#diagram').offset().top + floating.$elt.outerHeight() / 2;
    x = (x - diagram.zoom.translate[0]) / diagram.zoom.scale;
    y = (y - diagram.zoom.translate[1]) / diagram.zoom.scale;
    x = diagram.snap.x * Math.floor(x / diagram.snap.x);
    y = diagram.snap.y * Math.floor(y / diagram.snap.y);
    type = floating.$elt.attr('data-type');
    node_add(type, x, y);
    floating.$elt.remove();
    return floating = null;
  });

  edit_it = function(node, fun) {
    return node.on('dblclick', fun).dblTap(fun);
  };

  enter_node = function(nodes, connect) {
    var g;
    if (connect == null) {
      connect = true;
    }
    g = nodes.append('g').attr('class', 'element');
    g.append('path').attr('class', 'ghost');
    g.append('path').attr('class', function(node) {
      return "shape fill-" + node.cls.fill + " stroke-" + node.cls.stroke;
    });
    g.append('text');
    if (!connect) {
      return;
    }
    g.append('g').attr('class', 'handles').each(function(node) {
      return d3.select(this).selectAll('.handle').data(node.handle_list()).enter().append('path').attr('class', function(handle) {
        return "handle " + (handle.toLowerCase());
      }).call(nsweo_resize_drag);
    });
    g.append('g').attr('class', 'anchors').each(function(node) {
      return d3.select(this).selectAll('.anchor').data(node.anchor_list()).enter().append('path').attr('class', function(anchor) {
        return "anchor " + anchor;
      }).attr('data-anchor', function(anchor) {
        return anchor;
      }).call(anchor_link_drag);
    });
    g.call(move_drag);
    return g.call(mouse_node);
  };

  write_text = function(txt, text) {
    var i, line, tspan, _i, _len, _ref, _results;
    txt.selectAll('tspan').remove();
    _ref = text.split('\n');
    _results = [];
    for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
      line = _ref[i];
      tspan = txt.append('tspan').text(line).attr('x', 0);
      if (i !== 0) {
        _results.push(tspan.attr('dy', '1.2em'));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  update_node = function(nodes) {
    nodes.select('text').each(function(node) {
      var current_text, txt;
      txt = d3.select(this);
      current_text = txt.selectAll('tspan')[0].map(function(e) {
        return d3.select(e).text();
      }).join('\n');
      if (node.text === current_text) {
        return;
      }
      return txt.call(write_text, node.text);
    }).each(function(node) {
      return node.set_txt_bbox(this.getBBox());
    }).attr('x', function(node) {
      return node.txt_x();
    }).attr('y', function(node) {
      return node.txt_y();
    }).selectAll('tspan').attr('x', function(node) {
      return node.txt_x();
    });
    nodes.select('.shape').attr('class', function(node) {
      return "shape fill-" + node.cls.fill + " stroke-" + node.cls.stroke;
    }).attr('style', node_style).attr('d', function(node) {
      return node.path();
    });
    nodes.select('.ghost').attr('d', function(node) {
      if (!(node instanceof Group)) {
        return Rect.prototype.path.apply(node);
      } else {
        return 'M 0 0';
      }
    });
    nodes.call(update_handles);
    return nodes.call(update_anchors);
  };

  enter_link = function(links, connect) {
    var g;
    if (connect == null) {
      connect = true;
    }
    g = links.append('g').attr("class", "link");
    g.append("path").attr('class', 'ghost');
    g.append("path").attr('class', function(link) {
      return "shape " + link.cls.type;
    }).attr("marker-start", function(link) {
      var _ref;
      return "url(#" + (((_ref = link.marker_start) != null ? _ref.id : void 0) || link.cls.marker_start.id) + ")";
    }).attr("marker-end", function(link) {
      var _ref;
      return "url(#" + (((_ref = link.marker_end) != null ? _ref.id : void 0) || link.cls.marker_end.id) + ")";
    });
    g.each(function(link) {
      var node, txt;
      node = d3.select(this);
      if (link.text.source) {
        txt = node.append("text").attr('class', "start").call(write_text, link.text.source);
        link._source_bbox = txt.node().getBBox();
      }
      if (link.text.target) {
        txt = node.append("text").attr('class', "end").call(write_text, link.text.target);
        return link._target_bbox = txt.node().getBBox();
      }
    });
    if (connect) {
      g.call(mouse_link);
      return g.call(link_drag);
    }
  };

  update_link = function(links) {
    links.each(function(link) {
      var _ref, _ref1;
      return d3.select(this).selectAll('path').attr('d', link.path()).attr("marker-start", "url(#" + (((_ref1 = link.marker_start) != null ? _ref1.id : void 0) || link.cls.marker_start.id) + ")").attr("marker-end", "url(#" + (((_ref = link.marker_end) != null ? _ref.id : void 0) || link.cls.marker_end.id) + ")");
    });
    links.each(function(link) {
      var g, txt;
      g = d3.select(this);
      txt = g.select('text.start').node();
      if (link.text.source && !txt) {
        g.append('text').attr('class', 'start');
      }
      txt = g.select('text.end').node();
      if (link.text.target && !txt) {
        g.append('text').attr('class', 'end');
      }
      return g.select('.shape').attr('style', node_style);
    });
    links.select('text.start').each(function(link) {
      var text, txt;
      txt = d3.select(this);
      text = txt.text();
      if (link.text.source === text && (link._source_bbox != null)) {
        return;
      }
      if (link.text.source.trim() === '') {
        txt.remove();
        return;
      }
      txt.call(write_text, link.text.source);
      return link._source_bbox = txt.node().getBBox();
    });
    return links.select('text.end').each(function(link) {
      var text, txt;
      txt = d3.select(this);
      text = txt.text();
      if (!link.text.target === text && (link._target_bbox != null)) {
        return;
      }
      if (link.text.target.trim() === '') {
        txt.remove();
        return;
      }
      txt.call(write_text, link.text.target);
      return link._target_bbox = txt.node().getBBox();
    });
  };

  update_handles = function(nodes) {
    return nodes.each(function(node) {
      var s;
      s = node.cls.handle_size;
      return d3.select(this).selectAll('.handle').data(node.handle_list()).attr('d', function(handle) {
        var h, signs;
        h = node.handles[handle]();
        if (handle !== 'O') {
          signs = cardinal_to_direction(handle);
          return "M " + h.x + " " + h.y + " L " + (h.x + signs.x * s) + " " + h.y + " L " + (h.x + signs.x * s) + " " + (h.y + signs.y * s) + " L " + h.x + " " + (h.y + signs.y * s) + " z";
        } else {
          return "M " + h.x + " " + h.y + " L " + h.x + " " + (h.y - 2 * s) + " A " + s + " " + s + " 0 1 1 " + h.x + " " + (h.y - 4 * s) + " A " + s + " " + s + " 0 1 1 " + h.x + " " + (h.y - 2 * s);
        }
      });
    });
  };

  update_anchors = function(nodes) {
    return nodes.each(function(node) {
      var s;
      s = node.cls.handle_size;
      return d3.select(this).selectAll('.anchor').data(node.anchor_list()).attr('transform', function(anchor) {
        var a;
        a = node.anchors[anchor]();
        return "rotate(" + (to_svg_angle(anchor)) + ", " + (a.x - node.x) + ", " + (a.y - node.y) + ")";
      }).attr('d', function(anchor) {
        var a;
        a = node.anchors[anchor]();
        if (void 0 === a.x || void 0 === a.y || void 0 === node.x || void 0 === node.y) {
          return 'M 0 0';
        }
        a.x -= node.x;
        a.y -= node.y;
        return "M " + a.x + " " + a.y + " L " + a.x + " " + (a.y + s) + " L " + (a.x + s) + " " + a.y + " L " + a.x + " " + (a.y - s) + " z";
      });
    });
  };

  tick_node = function(nodes) {
    return nodes.attr("transform", (function(node) {
      return "translate(" + node.x + "," + node.y + ")rotate(" + (to_svg_angle(node._rotation)) + ")";
    })).classed('selected', function(node) {
      return __indexOf.call(diagram.selection, node) >= 0;
    });
  };

  tick_link = function(links) {
    links.classed('selected', function(link) {
      return __indexOf.call(diagram.selection, link) >= 0;
    });
    links.each(function(link) {
      return d3.select(this).selectAll('path').attr('d', link.path());
    });
    links.select('text.start').attr('transform', function(link) {
      var bb, delta, pos;
      bb = link._source_bbox;
      pos = {
        x: link.text_margin + bb.width / 2,
        y: link.text_margin + bb.height / 2
      };
      delta = rotate(pos, link.o1 + 3 * pi / 2);
      return "translate(" + (link.a1.x + delta.x) + ", " + (link.a1.y + delta.y) + ")";
    });
    return links.select('text.end').attr('transform', function(link) {
      var bb, delta, pos;
      bb = link._target_bbox;
      pos = {
        x: link.text_margin + bb.width / 2,
        y: link.text_margin + bb.height / 2
      };
      delta = rotate(pos, link.o2 + 3 * pi / 2);
      return "translate(" + (link.a2.x + delta.x) + ", " + (link.a2.y + delta.y) + ")";
    });
  };

  enter_marker = function(markers, open) {
    if (open == null) {
      open = false;
    }
    return markers.append('marker').append('path');
  };

  update_marker = function(markers) {
    return markers.attr('id', function(m) {
      return m.id;
    }).attr('class', function(m) {
      return "marker fill-" + (m.open ? 'bg' : 'fg') + " stroke-fg";
    }).attr('viewBox', function(m) {
      return m.viewbox();
    }).attr('markerUnits', 'userSpaceOnUse').attr('markerWidth', function(m) {
      return m.width();
    }).attr('markerHeight', function(m) {
      return m.height();
    }).attr('orient', 'auto').each(function(m) {
      return d3.select(this).select('path').attr('d', m.path());
    });
  };

  mouse_xy = function(e) {
    var m;
    m = d3.mouse(e);
    return {
      x: (m[0] - diagram.zoom.translate[0]) / diagram.zoom.scale,
      y: (m[1] - diagram.zoom.translate[1]) / diagram.zoom.scale
    };
  };

  zoom = d3.behavior.zoom();

  Svg = (function(_super) {
    __extends(Svg, _super);

    function Svg() {
      this.create = __bind(this.create, this);
      var article;
      Svg.__super__.constructor.apply(this, arguments);
      article = d3.select("article").node();
      this.width = article.clientWidth;
      this.height = article.clientHeight || 500;
      this.zoom = zoom.scale(diagram.zoom.scale).translate(diagram.zoom.translate).scaleExtent([.05, 5]).on("zoom", function() {
        if (!d3.event.sourceEvent.shiftKey) {
          diagram.zoom.translate = d3.event.translate;
          diagram.zoom.scale = d3.event.scale;
          return svg.sync_transform();
        }
      }).on("zoomend", function() {
        return svg.sync(true);
      });
      d3.select(".inside").selectAll('svg').data([diagram]).enter().append("svg").attr('id', "diagram").attr("width", this.width).attr("height", this.height).call(this.create);
      this.svg = d3.select('#diagram').call(svg_selection_drag);
    }

    Svg.prototype.sync_transform = function() {
      d3.select('.root').attr("transform", "translate(" + diagram.zoom.translate + ")scale(" + diagram.zoom.scale + ")");
      return d3.select('#grid').attr("patternTransform", "translate(" + diagram.zoom.translate + ")scale(" + diagram.zoom.scale + ")");
    };

    Svg.prototype.create = function(svg) {
      var background, background_g, defs, pattern, root;
      defs = svg.append('defs');
      background_g = svg.append('g').attr('id', 'bg');
      background = background_g.append('rect').attr('class', 'background').attr('width', this.width).attr('height', this.height).attr('fill', 'url(#grid)').call(this.zoom);
      svg.append('text').attr('id', 'title').attr('x', this.width / 2).attr('y', 50).call(edit_it, function() {
        return edit((function() {
          return diagram.title;
        }), (function(txt) {
          return diagram.title = txt;
        }), false);
      });
      d3.select(window).on('resize', (function(_this) {
        return function() {
          return _this.resize();
        };
      })(this));
      pattern = defs.append('pattern').attr('id', 'grid').attr('viewBox', '0 0 10 10').attr('x', 0).attr('y', 0).attr('width', diagram.snap.x).attr('height', diagram.snap.y).attr('patternUnits', 'userSpaceOnUse');
      pattern.append('path').attr('d', 'M 10 0 L 0 0 L 0 10');
      root = background_g.append('g').attr('class', 'root');
      root.append('g').attr('class', 'underlay');
      root.append('g').attr('class', 'links');
      root.append('g').attr('class', 'elements');
      return root.append('g').attr('class', 'overlay');
    };

    Svg.prototype.sync = function(persist) {
      var element, link, markers;
      if (persist == null) {
        persist = false;
      }
      this.zoom.scale(diagram.zoom.scale);
      this.zoom.translate(diagram.zoom.translate);
      this.sync_transform();
      this.svg.select('#title').text(diagram.title);
      markers = this.svg.select('defs').selectAll('marker').data(diagram.markers());
      markers.enter().call(enter_marker);
      markers.call(update_marker);
      markers.exit().remove();
      element = this.svg.select('g.elements').selectAll('g.element').data(diagram.elements.sort(order));
      link = this.svg.select('g.links').selectAll('g.link').data(diagram.links.concat(diagram.linking));
      element.enter().call(enter_node);
      link.enter().call(enter_link);
      element.call(update_node);
      link.call(update_link);
      element.exit().remove();
      link.exit().remove();
      this.tick();
      if (persist && !diagram.force) {
        generate_url();
      }
      if (diagram.force) {
        diagram.force.stop();
        diagram.force.nodes(diagram.elements).links(diagram.links);
        return diagram.force.start();
      }
    };

    Svg.prototype.tick = function() {
      this.svg.select('g.elements').selectAll('g.element').call(tick_node);
      return this.svg.select('g.links').selectAll('g.link').call(tick_link);
    };

    Svg.prototype.resize = function() {
      var article;
      article = d3.select(".inside").node();
      this.width = article.clientWidth;
      this.height = article.clientHeight || 500;
      this.svg.attr("width", this.width).attr("height", this.height);
      d3.select('.background').attr("width", this.width).attr("height", this.height);
      return this.svg.select('#title').attr('x', this.width / 2);
    };

    return Svg;

  })(Base);

  load = function(data) {
    var Type;
    Type = Diagrams._get(data.name);
    window.diagram = new Type();
    window.svg = new Svg();
    return diagram.loads(data);
  };

  save = function() {
    return localStorage.setItem("" + diagram.cls.name + "|" + diagram.title, diagram.hash());
  };

  generate_url = function() {
    var hash;
    if (!location.hash) {
      return;
    }
    hash = '#' + diagram.hash();
    if (location.hash !== hash) {
      return history.pushState(null, null, hash);
    }
  };

  history_pop = function() {
    var $diagrams, $editor, e1, e2, e21, e22, e3, e4, ex1, ex2, link, note;
    $diagrams = $('#diagrams');
    $editor = $('#editor');
    if (!location.hash) {
      if (!$editor.hasClass('hidden')) {
        $diagrams.removeClass('hidden');
        $editor.addClass('hidden');
        $('aside h3').attr('id', '');
        list_diagrams();
      }
      return;
    }
    $editor.removeClass('hidden');
    $diagrams.addClass('hidden');
    if (location.search === '?nocatch/') {
      load(JSON.parse(LZString.decompressFromBase64(location.hash.slice(1))));
    } else {
      try {
        load(JSON.parse(LZString.decompressFromBase64(location.hash.slice(1))));
      } catch (_error) {
        ex1 = _error;
        try {
          load(JSON.parse(decodeURIComponent(escape(atob(location.hash.slice(1))))));
        } catch (_error) {
          ex2 = _error;
          window.diagram = new Diagrams.Dot();
          note = Diagrams.Dot.prototype.types.elements.Note;
          link = Diagrams.Dot.prototype.types.links.Link;
          window.svg = new Svg();
          diagram.title = 'There was an error loading your diagram :(';
          diagram.elements.push(e1 = new note(void 0, void 0, ex1.message));
          diagram.elements.push(e2 = new note(void 0, void 0, ex1.stack));
          diagram.elements.push(e21 = new note(void 0, void 0, ex2.message));
          diagram.elements.push(e22 = new note(void 0, void 0, ex2.stack));
          diagram.elements.push(e3 = new note(void 0, void 0, 'You can try to reload\nyour browser without cache'));
          diagram.elements.push(e4 = new note(void 0, void 0, 'Otherwise it may be that\n your diagram is not compatible\nwith this version'));
          diagram.links.push(new link(e2, e1));
          diagram.links.push(new link(e2, e3));
          diagram.links.push(new link(e2, e4));
          diagram.links.push(new link(e21, e1));
          diagram.links.push(new link(e22, e2));
          diagram.links.push(new link(e21, e22));
          diagram.start_force();
        }
      }
    }
    init_commands();
    svg.resize();
    if ('webkitRequestAnimationFrame' in window) {
      setTimeout((function() {
        return svg.sync();
      }), 50);
    }
    return svg.sync();
  };

  list_local = function() {
    var $tbody, $tr, b64_diagram, key, title, type, _ref;
    $tbody = $('.table.local tbody');
    $tbody.find('tr').remove();
    $('.local').show();
    for (key in localStorage) {
      b64_diagram = localStorage[key];
      _ref = key.split('|'), type = _ref[0], title = _ref[1];
      if (title == null) {
        continue;
      }
      $tbody.append($tr = $('<tr>'));
      $tr.append($('<td>').text(title), $('<td>').text((new (Diagrams._get(type))()).label), $('<td>').append($('<a>').attr('href', "#" + b64_diagram).append($('<i>', {
        "class": 'glyphicon glyphicon-folder-open'
      }))).append($('<a>').attr('href', "#").append($('<i>', {
        "class": 'glyphicon glyphicon-trash'
      })).on('click', (function(k) {
        return function() {
          localStorage.removeItem(k);
          $(this).closest('tr').remove();
          return false;
        };
      })(key))));
    }
    if (!$tbody.find('tr').size()) {
      return $('.local').hide();
    }
  };

  list_new = function() {
    var $tbody, $tr, b64_diagram, diagram, name, type, _results;
    $tbody = $('.table.new tbody');
    $tbody.find('tr').remove();
    _results = [];
    for (name in Diagrams) {
      type = Diagrams[name];
      if (name.match(/^_/)) {
        continue;
      }
      diagram = new type();
      b64_diagram = diagram.hash();
      $tbody.append($tr = $('<tr>'));
      _results.push($tr.append($('<td>').text(diagram.label), $('<td>').append($('<a>').attr('href', "#" + b64_diagram).append($('<i>', {
        "class": 'glyphicon glyphicon-file'
      })))));
    }
    return _results;
  };

  list_diagrams = function() {
    list_local();
    return list_new();
  };

  KEYWORDS = ['node', 'edge', 'graph', 'digraph', 'subgraph', 'strict'];

  BRACES = ['[', '{', '}', ']'];

  DELIMITERS = [':', ';', ','];

  OPERATORS = ['--', '->'];

  COMPASS_PTS = ['n', 'ne', 'e', 'se', 's', 'sw', 'w', 'nw', 'c', '_'];

  RE_SPACE = /\s/;

  RE_ALPHA = /[a-zA-Z_\u00C0-\u017F]/;

  RE_DIGIT = /\d|\./;

  RE_ALPHADIGIT = /[a-zA-Z0-9_\u00C0-\u017F]/;

  RE_COMMENT = /\/|\#/;

  PANIC_THRESHOLD = 9999;

  ParserError = (function() {
    function ParserError(message) {
      this.message = message;
    }

    return ParserError;

  })();

  Token = (function() {
    function Token(value) {
      this.value = value;
    }

    return Token;

  })();

  Keyword = (function(_super) {
    __extends(Keyword, _super);

    function Keyword() {
      return Keyword.__super__.constructor.apply(this, arguments);
    }

    return Keyword;

  })(Token);

  Id = (function(_super) {
    __extends(Id, _super);

    function Id() {
      return Id.__super__.constructor.apply(this, arguments);
    }

    return Id;

  })(Token);

  Number = (function(_super) {
    __extends(Number, _super);

    function Number() {
      return Number.__super__.constructor.apply(this, arguments);
    }

    return Number;

  })(Id);

  QuotedId = (function(_super) {
    __extends(QuotedId, _super);

    function QuotedId() {
      return QuotedId.__super__.constructor.apply(this, arguments);
    }

    return QuotedId;

  })(Id);

  Brace = (function(_super) {
    __extends(Brace, _super);

    function Brace() {
      return Brace.__super__.constructor.apply(this, arguments);
    }

    return Brace;

  })(Token);

  Delimiter = (function(_super) {
    __extends(Delimiter, _super);

    function Delimiter() {
      return Delimiter.__super__.constructor.apply(this, arguments);
    }

    return Delimiter;

  })(Token);

  Assign = (function(_super) {
    __extends(Assign, _super);

    function Assign() {
      return Assign.__super__.constructor.apply(this, arguments);
    }

    return Assign;

  })(Token);

  Operator = (function(_super) {
    __extends(Operator, _super);

    function Operator() {
      return Operator.__super__.constructor.apply(this, arguments);
    }

    return Operator;

  })(Token);

  dot_tokenize = function(s) {
    var chr, col, escape, id, last_chr, len, op, pos, row, token, tokens, _ref, _ref1;
    pos = 0;
    row = 0;
    col = 0;
    len = s.length;
    tokens = [];
    last_chr = chr = null;
    while (pos < len) {
      last_chr = chr;
      token = null;
      col++;
      chr = s[pos++];
      if (chr.match(RE_SPACE)) {
        if (chr === '\n') {
          row++;
          col = 0;
        }
        continue;
      } else if (chr === '=') {
        token = new Assign(chr);
      } else if (chr === '-') {
        op = chr + s[pos++];
        if (__indexOf.call(OPERATORS, op) >= 0) {
          token = new Operator(op);
        }
      } else if (__indexOf.call(BRACES, chr) >= 0) {
        token = new Brace(chr);
      } else if (__indexOf.call(DELIMITERS, chr) >= 0) {
        token = new Delimiter(chr);
      } else if (chr.match(RE_ALPHA)) {
        id = chr;
        while ((_ref = (chr = s[pos++])) != null ? _ref.match(RE_ALPHADIGIT) : void 0) {
          id += chr;
        }
        pos--;
        if (__indexOf.call(KEYWORDS, id) >= 0) {
          token = new Keyword(id);
        } else {
          token = new Id(id);
        }
      } else if (chr === '"') {
        id = '';
        escape = false;
        while (((chr = s[pos++]) !== '"' || escape) && (chr != null)) {
          if (chr === '\\' && !escape) {
            escape = true;
            continue;
          }
          if (escape) {
            if (chr === 'n') {
              chr = '\n';
            } else if (chr === 't') {
              chr = '\t';
            } else if (chr === 'r') {
              chr = '\r';
            } else if (chr === '"') {
              chr = '"';
            } else if (chr === '\\') {
              chr = '\\';
            } else if (chr === '\n') {
              chr = '';
            }
          }
          id += chr;
          escape = false;
        }
        token = new QuotedId(id);
      } else if (chr.match(RE_DIGIT)) {
        id = chr;
        while ((_ref1 = (chr = s[pos++])) != null ? _ref1.match(RE_DIGIT) : void 0) {
          id += chr;
        }
        pos--;
        token = new Number(parseFloat(id));
      } else if (chr.match(RE_COMMENT)) {
        if (chr === '/' && s[pos] === '*') {
          pos += 2;
          while (!((chr = s[pos]) === '*' && s[pos + 1] === '/') && (chr != null)) {
            if (chr === '\n') {
              row++;
              col = 0;
            } else {
              col++;
            }
            pos++;
          }
          pos += 2;
        } else {
          if (chr === '#' || (chr === '/' && s[pos] === '/')) {
            while (!((chr = s[pos]) === '\n') && (chr != null)) {
              col++;
              pos++;
            }
          }
        }
      } else {
        throw new ParserError("Syntax error in dot " + chr + " at " + row + ", " + col);
      }
      if (token) {
        tokens.push(token);
      }
    }
    return tokens;
  };

  Graph = (function() {
    function Graph(type, id, strict) {
      this.type = type;
      this.id = id;
      this.strict = strict;
      this.statements = [];
    }

    return Graph;

  })();

  Statement = (function() {
    function Statement() {}

    Statement.prototype.get_attrs = function() {
      var attribute, attrs, _i, _len, _ref;
      attrs = {};
      _ref = this.attributes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        attribute = _ref[_i];
        attrs[attribute.left] = attribute.right;
      }
      return attrs;
    };

    return Statement;

  })();

  SubGraph = (function() {
    function SubGraph(id) {
      this.id = id;
      this.statements = [];
    }

    return SubGraph;

  })();

  Node = (function(_super) {
    __extends(Node, _super);

    function Node(id, port, compass_pt) {
      this.id = id;
      this.port = port;
      this.compass_pt = compass_pt;
    }

    return Node;

  })(Statement);

  Edge = (function(_super) {
    __extends(Edge, _super);

    function Edge() {
      this.nodes = [];
      this.attributes = [];
    }

    return Edge;

  })(Statement);

  Attribute = (function() {
    function Attribute(left, right) {
      this.left = left;
      this.right = right;
    }

    return Attribute;

  })();

  Attributes = (function(_super) {
    __extends(Attributes, _super);

    function Attributes(type) {
      this.type = type;
      this.attributes = [];
    }

    return Attributes;

  })(Statement);

  dot_lex = function(tokens) {
    var graph, id, level, parse_attribute, parse_attribute_list, parse_node, parse_node_list, parse_statement, parse_statement_list, parse_subgraph, pos, strict, type;
    pos = 0;
    level = 0;
    if (!(tokens[pos] instanceof Keyword)) {
      throw new ParserError('First token is not a keyword');
    }
    strict = false;
    if (tokens[pos].value === 'strict') {
      strict = true;
      pos++;
    }
    type = null;
    if (tokens[pos].value === 'graph') {
      type = 'normal';
    } else if (tokens[pos].value === 'digraph') {
      type = 'directed';
    }
    if (type === null) {
      throw new ParserError('Unknown graph type');
    }
    id = null;
    if (tokens[++pos] instanceof Id) {
      id = tokens[pos++].value;
    }
    parse_attribute = function() {
      var left, right;
      if (tokens[pos] instanceof Brace && tokens[pos].value === ']') {
        if (tokens[pos + 1] instanceof Brace && tokens[pos + 1].value === '[') {
          pos += 2;
        } else {
          return null;
        }
      }
      if (!(tokens[pos] instanceof Id)) {
        throw new ParserError("Invalid left hand side of attribute '" + tokens[pos].value + "'");
      }
      left = tokens[pos].value;
      pos++;
      if (!(tokens[pos] instanceof Assign)) {
        throw new ParserError("Invalid assignement '" + tokens[pos].value + "'");
      }
      pos++;
      if (!(tokens[pos] instanceof Id)) {
        throw new ParserError("Invalid right hand side of attribute '" + tokens[pos].value + "'");
      }
      right = tokens[pos].value;
      return new Attribute(left, right);
    };
    parse_attribute_list = function() {
      var attribute, attributes, panic;
      if (!(tokens[pos] instanceof Brace && tokens[pos].value === '[')) {
        throw new ParserError('No opening brace "[" for attribute list');
      }
      pos++;
      attributes = [];
      panic = 0;
      while (panic++ < PANIC_THRESHOLD) {
        attribute = parse_attribute();
        if (attribute === null) {
          break;
        } else {
          pos++;
          attributes.push(attribute);
          if (tokens[pos] instanceof Delimiter && tokens[pos].value === ',') {
            pos++;
          }
        }
      }
      if (--panic === PANIC_THRESHOLD) {
        throw new ParserError('Infinite loop for statement list parsing');
      }
      return attributes;
    };
    parse_subgraph = function() {
      var subgraph;
      id = null;
      if (tokens[pos] instanceof Keyword && tokens[pos].value === 'subgraph') {
        pos++;
        if (tokens[pos] instanceof Id) {
          id = tokens[pos++].value;
        }
      }
      subgraph = new SubGraph(id);
      subgraph.statements = parse_statement_list();
      return subgraph;
    };
    parse_node = function() {
      var compass_pt, node, port, _ref;
      if (tokens[pos] instanceof Keyword && tokens[pos].value === 'subgraph') {
        node = parse_subgraph();
      } else if (tokens[pos] instanceof Brace && tokens[pos].value === '{') {
        node = parse_subgraph();
      } else {
        if (!(tokens[pos] instanceof Id)) {
          throw new ParserError("Invalid edge id '" + tokens[pos].value + "'");
        }
        id = tokens[pos].value;
        port = null;
        compass_pt = null;
        if (tokens[pos + 1] instanceof Delimiter && tokens[pos + 1].value === ':') {
          pos += 2;
          if (!(tokens[pos] instanceof Id)) {
            throw new ParserError("Invalid port id '" + tokens[pos].value + "'");
          }
          port = tokens[pos].value;
          if (tokens[pos + 1] instanceof Delimiter && tokens[pos + 1].value === ':') {
            pos += 2;
            if (!(tokens[pos] instanceof Id) || (_ref = tokens[pos].value, __indexOf.call(COMPASS_PTS, _ref) < 0)) {
              throw new ParserError("Invalid compass point '" + tokens[pos].value + "'");
            }
            compass_pt = tokens[pos].value;
          }
          if (port && !compass_pt && __indexOf.call(COMPASS_PTS, port) >= 0) {
            compass_pt = port;
            port = null;
          }
        }
        node = new Node(id, port, compass_pt);
      }
      return node;
    };
    parse_node_list = function() {
      var node_list;
      node_list = [parse_node()];
      while (tokens[pos + 1] instanceof Operator) {
        pos += 2;
        node_list.push(parse_node());
      }
      return node_list;
    };
    parse_statement = function() {
      var left, statement, _ref;
      if (tokens[pos] instanceof Brace && tokens[pos].value === '}') {
        return null;
      }
      if (tokens[pos] instanceof Keyword && tokens[pos].value !== 'subgraph') {
        if ((_ref = tokens[pos].value) !== 'graph' && _ref !== 'node' && _ref !== 'edge') {
          throw new ParserError('Unexpected keyword ' + tokens[pos]);
        }
        statement = new Attributes(tokens[pos++].value);
        statement.attributes = parse_attribute_list();
        return statement;
      }
      if (!(tokens[pos] instanceof Id || (tokens[pos] instanceof Keyword && tokens[pos].value === 'subgraph') || (tokens[pos] instanceof Brace && tokens[pos].value === '{'))) {
        throw new ParserError("Unexpected statement '" + tokens[pos].value + "'");
      }
      if (tokens[pos] instanceof Id && tokens[pos + 1] instanceof Assign) {
        left = tokens[pos].value;
        pos += 2;
        if (!(tokens[pos] instanceof Id)) {
          throw new ParserError("Invalid right hand side of attribute '" + tokens[pos].value + "'");
        }
        statement = new Attribute(left, tokens[pos].value);
        return statement;
      }
      statement = new Edge();
      statement.nodes = parse_node_list();
      if (tokens[pos + 1] instanceof Brace && tokens[pos + 1].value === '[') {
        pos++;
        statement.attributes = parse_attribute_list();
      }
      return statement;
    };
    parse_statement_list = function() {
      var panic, statement, statements;
      if (!(tokens[pos] instanceof Brace && tokens[pos].value === '{')) {
        throw ParserError('No opening brace "{" for statement list');
      }
      pos++;
      statements = [];
      panic = 0;
      while (panic++ < PANIC_THRESHOLD) {
        statement = parse_statement();
        if (statement === null) {
          break;
        } else {
          pos++;
          statements.push(statement);
          if (tokens[pos] instanceof Delimiter && tokens[pos].value === ';') {
            pos++;
          }
        }
      }
      if (--panic === PANIC_THRESHOLD) {
        throw ParserError('Infinite loop for statement list parsing');
      }
      return statements;
    };
    graph = new Graph(type, id, strict);
    graph.statements = parse_statement_list();
    if (pos + 1 !== tokens.length) {
      throw ParserError("Error in dot file, parsed " + pos + " elements out of " + tokens.length);
    }
    return window.g = graph;
  };

  dot = function(src) {
    var attributes, copy_attributes, d, e, elements_by_id, elt, fixed, graph, id, l, links_by_id, lnk, nodes_by_id, populate, tokens, x, y, _i, _len, _ref;
    tokens = dot_tokenize(src);
    graph = dot_lex(tokens);
    d = window.diagram = new Diagrams.Dot();
    window.svg = new Svg();
    nodes_by_id = {};
    links_by_id = [];
    attributes = {
      graph: {},
      edge: {},
      node: {}
    };
    copy_attributes = function() {
      return {
        graph: o_copy(attributes.graph),
        edge: o_copy(attributes.edge),
        node: o_copy(attributes.node)
      };
    };
    populate = function(statements) {
      var Type, current_attributes, i, label, ltype, node, old_attributes, prev_node, statement, sub_node, sub_prev_node, sub_prev_statement, sub_statement, type, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = statements.length; _i < _len; _i++) {
        statement = statements[_i];
        if (statement instanceof Attributes) {
          merge(attributes[statement.type], statement.get_attrs());
          continue;
        }
        if (statement instanceof Attribute) {
          attributes.graph[statement.left] = statement.right;
          continue;
        }
        if (!(statement instanceof Edge)) {
          console.log("Unexpected " + statement);
          continue;
        }
        current_attributes = copy_attributes();
        if (statement.nodes.length === 1) {
          merge(current_attributes.node, statement.get_attrs());
        } else {
          merge(current_attributes.edge, statement.get_attrs());
        }
        _results.push((function() {
          var _j, _len1, _ref, _results1;
          _ref = statement.nodes;
          _results1 = [];
          for (i = _j = 0, _len1 = _ref.length; _j < _len1; i = ++_j) {
            node = _ref[i];
            if (node instanceof SubGraph) {
              old_attributes = copy_attributes();
              populate(node.statements);
              attributes = old_attributes;
            } else {
              if (!(node.id in nodes_by_id) || statements.length === 1) {
                label = current_attributes.node.label || node.id;
                type = current_attributes.node.shape || 'ellipse';
                Type = d.types.elements[capitalize(type)] || d.types.elements.Ellipse;
                nodes_by_id[node.id] = {
                  label: label,
                  type: Type,
                  attrs: current_attributes.node
                };
              }
            }
            if (i !== 0) {
              prev_node = statement.nodes[i - 1];
              ltype = d.types.links.Link;
              if (prev_node instanceof SubGraph) {
                _results1.push((function() {
                  var _k, _len2, _ref1, _results2;
                  _ref1 = prev_node.statements;
                  _results2 = [];
                  for (_k = 0, _len2 = _ref1.length; _k < _len2; _k++) {
                    sub_prev_statement = _ref1[_k];
                    _results2.push((function() {
                      var _l, _len3, _ref2, _results3;
                      _ref2 = sub_prev_statement.nodes;
                      _results3 = [];
                      for (_l = 0, _len3 = _ref2.length; _l < _len3; _l++) {
                        sub_prev_node = _ref2[_l];
                        if (node instanceof SubGraph) {
                          _results3.push((function() {
                            var _len4, _m, _ref3, _results4;
                            _ref3 = node.statements;
                            _results4 = [];
                            for (_m = 0, _len4 = _ref3.length; _m < _len4; _m++) {
                              sub_statement = _ref3[_m];
                              _results4.push((function() {
                                var _len5, _n, _ref4, _results5;
                                _ref4 = sub_statement.nodes;
                                _results5 = [];
                                for (_n = 0, _len5 = _ref4.length; _n < _len5; _n++) {
                                  sub_node = _ref4[_n];
                                  _results5.push(links_by_id.push({
                                    type: ltype,
                                    id1: sub_prev_node.id,
                                    id2: sub_node.id,
                                    label: current_attributes.edge.label,
                                    attrs: current_attributes.edge
                                  }));
                                }
                                return _results5;
                              })());
                            }
                            return _results4;
                          })());
                        } else {
                          _results3.push(links_by_id.push({
                            type: ltype,
                            id1: sub_prev_node.id,
                            id2: node.id,
                            label: current_attributes.edge.label,
                            attrs: current_attributes.edge
                          }));
                        }
                      }
                      return _results3;
                    })());
                  }
                  return _results2;
                })());
              } else {
                if (node instanceof SubGraph) {
                  _results1.push((function() {
                    var _k, _len2, _ref1, _results2;
                    _ref1 = node.statements;
                    _results2 = [];
                    for (_k = 0, _len2 = _ref1.length; _k < _len2; _k++) {
                      sub_statement = _ref1[_k];
                      _results2.push((function() {
                        var _l, _len3, _ref2, _results3;
                        _ref2 = sub_statement.nodes;
                        _results3 = [];
                        for (_l = 0, _len3 = _ref2.length; _l < _len3; _l++) {
                          sub_node = _ref2[_l];
                          _results3.push(links_by_id.push({
                            type: ltype,
                            id1: prev_node.id,
                            id2: sub_node.id,
                            label: current_attributes.edge.label,
                            attrs: current_attributes.edge
                          }));
                        }
                        return _results3;
                      })());
                    }
                    return _results2;
                  })());
                } else {
                  _results1.push(links_by_id.push({
                    type: ltype,
                    id1: prev_node.id,
                    id2: node.id,
                    label: current_attributes.edge.label,
                    attrs: current_attributes.edge
                  }));
                }
              }
            } else {
              _results1.push(void 0);
            }
          }
          return _results1;
        })());
      }
      return _results;
    };
    populate(graph.statements);
    elements_by_id = {};
    fixed = true;
    for (id in nodes_by_id) {
      elt = nodes_by_id[id];
      elements_by_id[id] = e = new elt.type(void 0, void 0, elt.label);
      if (elt.attrs.pos) {
        if (elt.attrs.pos.indexOf('!') === elt.attrs.pos.length - 1) {
          e.fixed = true;
          elt.attrs.pos = elt.attrs.pos.slice(0, -1);
        }
        _ref = elt.attrs.pos.split(','), x = _ref[0], y = _ref[1];
        e.x = +x;
        e.y = +y;
        delete elt.attrs.pos;
      } else {
        fixed = false;
      }
      e.attrs = elt.attrs;
      diagram.elements.push(e);
    }
    for (_i = 0, _len = links_by_id.length; _i < _len; _i++) {
      lnk = links_by_id[_i];
      l = new lnk.type(elements_by_id[lnk.id1], elements_by_id[lnk.id2]);
      l.text.source = lnk.label;
      if (graph.type === 'directed' && !lnk.attrs.arrowhead) {
        lnk.attrs.arrowhead = 'normal';
      }
      if (lnk.attrs.arrowhead) {
        l.marker_end = Markers._get(lnk.attrs.arrowhead);
        delete lnk.attrs.arrowhead;
      }
      if (lnk.attrs.arrowtail) {
        l.marker_start = Markers._get(lnk.attrs.arrowtail, true);
        delete lnk.attrs.arrowtail;
      }
      if (lnk.attrs.headlabel) {
        l.text.target = lnk.attrs.headlabel;
        delete lnk.attrs.headlabel;
      }
      if (lnk.attrs.taillabel) {
        l.text.source = lnk.attrs.taillabel;
        delete lnk.attrs.taillabel;
      }
      l.attrs = lnk.attrs;
      diagram.links.push(l);
    }
    d.title = attributes.graph.label || graph.id;
    d.force = !fixed;
    return d.hash();
  };

  $((function(_this) {
    return function() {
      if (location.pathname.match(/\/test\//)) {
        return;
      }
      list_diagrams();
      $('.dot2umlaut').click(function() {
        return location.hash = dot($(this).siblings('textarea.dot').val());
      });
      _this.addEventListener("popstate", history_pop);
      if (location.hash) {
        return history_pop();
      }
    };
  })(this));

}).call(this);

//# sourceMappingURL=main.js.map
