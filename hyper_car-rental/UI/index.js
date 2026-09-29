$(document).ready(function() {
    $(".container").hide();

    window.addEventListener("message", function (event) {
        const data = event.data;

        if (data.action === "Open") {
            RenderList(data.vehicles || []);
            $(".container").fadeIn(250);
        }

        if (data.action === "Hide") {
            $(".container").fadeOut(250);
        }
    });

    document.addEventListener('keyup', function(event) {
        if (event.key === 'Escape') CloseUI();
    });

    $(".Exit").on("click", CloseUI);

    $(".List").on("click", ".rentButton", function() {
        const model = $(this).attr("data-model");
        PostNUI("Rent", { Model: model })
    })
});

function RenderList(vehicles) {
    const $list = $(".List").empty();

    vehicles.forEach(function(v) {
        const $card = $('<div class="Example1"></div>');

        $card.append($('<label class="carName"></label>').text(v.label));
        $card.append($('<label class="costs"></label>').text("$" + v.price + "/min"));
        $card.append($('<label class="liter"></label>').text(v.fuel + "L"));
        $card.append($('<button class="rentButton">RENT</button>').attr("data-model", v.model));

        $list.append($card);
    })
}

function CloseUI() {
    PostNUI("Close", {});
    $(".container").fadeOut(150);
}

function PostNUI(endpoint, data) {
    return fetch(`https://${GetParentResourceName()}/${endpoint}`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(data)
    });
}