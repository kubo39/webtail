'use strict';
const LINESIZE = 20;
const WS_PORT = 8080;
const WS_HOST = location.hostname;


class Model {
    constructor(view) {
        this.view = view;
        this.log = [];
        var source = new WebSocket(`ws://${WS_HOST}:${WS_PORT}/live`);
        source.onmessage = (m) => {
            if (this.log.length >= LINESIZE) {
                this.log.shift();
            }
            this.log.push(m.data);
            this.change();
        };
    }

    change() {
        this.view.render(this);
    }
}


class View {
    constructor() {
        this.target = document.getElementById("console");
        this.oldContainer;
    }

    render(model) {
        var container = document.createElement("div");
        var pres = model.log.map((data) => {
            var pre = document.createElement("pre");
            pre.textContent = data;
            return pre;
        });
        pres.forEach((pre) => container.appendChild(pre));
        if (this.oldContainer) {
            this.target.replaceChild(container, this.oldContainer);
        }
        else {
            this.target.appendChild(container);
        }
        this.oldContainer = container;
        window.scrollBy(0, 50);
    }
}


var model = new Model(new View());
