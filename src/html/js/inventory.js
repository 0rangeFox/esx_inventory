let type = "normal";
let firstTier = 1;
let firstUsed = 0;
const firstItems = [];
let secondTier = 1;
let secondUsed = 0;
const secondItems = [];
let errorHighlightTimer = null;
let originOwner = false;
let destinationOwner = false;
let locked = false;

let playerWeight = 0;
let secondWeight = 0;
let playerMoney = 0;

let dragging = false;
let origDrag = null;
let draggingItem = null;
const givingItem = null;
const mousedown = false;
const docWidth = document.documentElement.clientWidth;
const docHeight = document.documentElement.clientHeight;
const offset = [155, 125];
let cursorX = docWidth / 2;
let cursorY = docHeight / 2;

const successAudio = document.createElement('audio');
successAudio.controls = false;
successAudio.volume = 0.25;
successAudio.src = './success.wav';

const failAudio = document.createElement('audio');
failAudio.controls = false;
failAudio.volume = 0.1;
failAudio.src = './fail2.wav';

window.addEventListener("message", function(event) {
    if (event.data.action === "display") {
        type = event.data.type;

        if (type === "normal")
            $('#inventoryTwo').parent().hide();
        else if (type === "secondary")
            $('#inventoryTwo').parent().show();

        $(".ui").fadeIn();
    } else if (event.data.action === "hide") {
        if (event.data.type === 'secondary')
            $('#inventoryTwo').parent().hide();
        else {
            $("#dialog").dialog("close");
            $(".ui").fadeOut();
        }
    } else if (event.data.action === "setItems") {
        firstTier = event.data.invTier;
        originOwner = event.data.invOwner;
        inventorySetup(event.data.invOwner, event.data.itemList, event.data.money, event.data.invTier);

        if ($('#search').val() !== '')
            SearchInventory($('#search').val());
    } else if (event.data.action === "setSecondInventoryItems") {
        secondTier = event.data.invTier;
        destinationOwner = event.data.invOwner;
        secondInventorySetup(event.data.invOwner, event.data.itemList, event.data.invTier, event.data.money);

        if ($('#search').val() !== '')
            SearchInventory($('#search').val());
    } else if (event.data.action === "setInfoText")
        $(".info-div").html(event.data.text);
    else if (event.data.action === 'itemUsed')
        ItemUsed(event.data.alerts);
    else if (event.data.action === 'showActionBar')
        ActionBar(event.data.items);
    else if (event.data.action === 'actionbarUsed')
        ActionBarUsed(event.data.index);
    else if (event.data.action === 'unlock')
        UnlockInventory()
    else if (event.data.action === 'lock')
        LockInventory()
});

function formatCurrency(x) {
    return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

function EndDragging() {
    $(origDrag).removeClass('orig-dragging');
    $("#use").removeClass("disabled");
    $(draggingItem).remove();
    origDrag = null;
    draggingItem = null;
    dragging = false;
}

function closeInventory() {
    InventoryLog('Closing');
    EndDragging();
    $.post("http://esx_inventory/NUIFocusOff", JSON.stringify({}));
    $('#search').val('');
}

function inventorySetup(invOwner, items, money, invTier) {
    setupweight(items, 'invnetory1')
    setupPlayerSlots();    
    $('#player-inv-label').html(firstTier.label + '-' + invOwner);
    $('#player-inv-id').html('Weight: ' + (playerWeight).toFixed(1) + ' / ' + (firstTier.maxWeight).toFixed(1) + ' KG');
    $('#inventoryOne').data('invOwner', invOwner);
    $('#inventoryOne').data('invTier', invTier);


    firstUsed = 0;
    $.each(items, function(index, item) {
        const slot = $('#inventoryOne').find('.slot').filter(function () {
            return $(this).data('slot') === item.slot;
        });

        firstUsed++;
        const slotId = $(slot).data('slot');
        firstItems[slotId] = item;
        AddItemToSlot(slot, item);
    });

    $('#player-used').html(firstUsed);
    $("#inventoryOne > .slot:lt(5) .item").append('<div class="item-keybind"></div>');

    $('#inventoryOne .item-keybind').each(function(index) {
        $(this).html(index + 1);
    })
}

function secondInventorySetup(invOwner, items, invTier, money) {
    setupweight(items, 'second')
    setupSecondarySlots(invOwner);
    $('#other-inv-label').html(secondTier.label + '-' + invOwner);
    $('#other-inv-id').html('Weight: ' + (secondWeight).toFixed(1) + ' / ' + (secondTier.maxWeight).toFixed(1) + ' KG');
    $('#inventoryTwo').data('invOwner', invOwner);
    $('#inventoryTwo').data('invTier', invTier);

    secondUsed = 0;
    $.each(items, function(index, item) {
        const slot = $('#inventoryTwo').find('.slot').filter(function () {
            return $(this).data('slot') === item.slot;
        });
        secondUsed++;
        const slotId = $(slot).data('slot');
        secondItems[slotId] = item;
        AddItemToSlot(slot, item);
    });

    $('#other-used').html(secondUsed);
}

function setupPlayerSlots() {
    $('#inventoryOne').html("");
    $('#player-inv-id').html("");
    $('#inventoryOne').removeData('invOwner');
    $('#inventoryOne').removeData('invTier');
    $('#player-max').html(firstTier.slots);
    for (i = 1; i <= (firstTier.slots); i++) {
        $("#inventoryOne").append($('.slot-template').clone());
        $('#inventoryOne').find('.slot-template').data('slot', i);
        $('#inventoryOne').find('.slot-template').data('inventory', 'inventoryOne');
        $('#inventoryOne').find('.slot-template').removeClass('slot-template');
    }
}

function setupSecondarySlots(owner) {
    $('#inventoryTwo').html("");
    $('#other-inv-id').html("");
    $('#inventoryTwo').removeData('invOwner');
    $('#inventoryTwo').removeData('invTier');
    $('#other-max').html(secondTier.slots);
    for (i = 1; i <= (secondTier.slots); i++) {
        $("#inventoryTwo").append($('.slot-template').clone());
        $('#inventoryTwo').find('.slot-template').data('slot', i);
        $('#inventoryTwo').find('.slot-template').data('inventory', 'inventoryTwo');

        if (owner.startsWith("drop") || owner.startsWith("container") || owner.startsWith("car") || owner.startsWith("pd-trash"))
            $('#inventoryTwo').find('.slot-template').addClass('temporary');
        else if (owner.startsWith("pv") || owner.startsWith("stash"))
            $('#inventoryTwo').find('.slot-template').addClass('storage');
        else if (owner.startsWith("steam"))
            $('#inventoryTwo').find('.slot-template').addClass('player');
        else if (owner.startsWith("pd-evidence"))
            $('#inventoryTwo').find('.slot-template').addClass('evidence');

        $('#inventoryTwo').find('.slot-template').removeClass('slot-template');
    }
}

document.addEventListener('mousemove', function(event) {
    event.preventDefault();
    cursorX = event.clientX;
    cursorY = event.clientY;
    if (dragging)
        if (draggingItem !== undefined && draggingItem !== null) {
            draggingItem.css('left', (cursorX - offset[0]) + 'px');
            draggingItem.css('top', (cursorY - offset[1]) + 'px');
        }
}, true);

$('#count').on('keyup blur', function(e) {
    if ((e.which === 8 || e.which === undefined || e.which === 0))
        e.preventDefault();
    $(this).val() === '' ? $(this).val('0') : $(this).val(parseInt($(this).val()));
});

$(document).ready(function() {
    $('#inventoryOne, #inventoryTwo').on('click', '.slot', function(e) {
        if (locked)
            return

        const itemData = $(this).find('.item').data('item');
        if (itemData == null && !dragging)
            return

        if (dragging) {
            let moveCount = parseInt($("#count").val());
            const item = origDrag.find('.item').data('item');

            try {
                console.log("inventory.js | #001 | ", JSON.stringify(item))
                item.qty
            } catch (error) {
                EndDragging();
            }

            if (moveCount > item.qty || moveCount === 0)
                moveCount = item.qty;

            if (origDrag.data('invOwner') === $(this).parent().data('invOwner')) {
                if ($(this).data('slot') !== undefined && $(origDrag).data('slot') !== $(this).data('slot') || $(this).data('slot') !== undefined && $(origDrag).data('invOwner') !== $(this).parent().data('invOwner')) {
                    $(this).find('.item').data('item') !== undefined ? AttemptDropInOccupiedSlot(origDrag, $(this), parseInt($("#count").val())) : AttemptDropInEmptySlot(origDrag, $(this), parseInt($("#count").val()));
                    EndDragging();
                } else
                    successAudio.play();
                EndDragging();
            } else {
                if ($(this).data('inventory') === 'inventoryOne') {
                    if (firstTier.maxWeight >= playerWeight + (item.weight * moveCount)) {
                        if (secondTier.name === 'shop') {
                            if (0 <= (playerMoney - item.price * moveCount)) {
                                if ($(this).data('slot') !== undefined && $(origDrag).data('slot') !== $(this).data('slot') || $(this).data('slot') !== undefined && $(origDrag).data('invOwner') !== $(this).parent().data('invOwner'))
                                    $(this).find('.item').data('item') !== undefined ? AttemptDropInOccupiedSlot(origDrag, $(this), parseInt($("#count").val())) : AttemptDropInEmptySlot(origDrag, $(this), parseInt($("#count").val()));
                                else
                                    successAudio.play();
                                EndDragging();
                            } else {
                                $.post("http://esx_inventory/MoneyError")
                                EndDragging();
                            }
                        } else {
                            if ($(this).data('slot') !== undefined && $(origDrag).data('slot') !== $(this).data('slot') || $(this).data('slot') !== undefined && $(origDrag).data('invOwner') !== $(this).parent().data('invOwner'))
                                $(this).find('.item').data('item') !== undefined ? AttemptDropInOccupiedSlot(origDrag, $(this), parseInt($("#count").val())) : AttemptDropInEmptySlot(origDrag, $(this), parseInt($("#count").val()));
                            else
                                successAudio.play();
                            EndDragging();
                        }
                    } else {
                        $.post("http://esx_inventory/WeightError");
                        EndDragging();
                    }
                } else {
                    if (secondTier.maxWeight >= secondWeight + (item.weight * moveCount)) {
                        if ($(this).data('slot') !== undefined && $(origDrag).data('slot') !== $(this).data('slot') || $(this).data('slot') !== undefined && $(origDrag).data('invOwner') !== $(this).parent().data('invOwner'))
                            $(this).find('.item').data('item') !== undefined ? AttemptDropInOccupiedSlot(origDrag, $(this), parseInt($("#count").val())) : AttemptDropInEmptySlot(origDrag, $(this), parseInt($("#count").val()));
                        else
                            successAudio.play();
                        EndDragging();
                    } else {
                        $.post("http://esx_inventory/WeightError");
                        EndDragging();
                    }
                }
            }
        } else {
            if (itemData !== undefined) {
                // Store a reference because JS is retarded
                origDrag = $(this);
                AddItemToSlot(origDrag, itemData);
                $(origDrag).data('slot', $(this).data('slot'));
                $(origDrag).data('invOwner', $(this).parent().data('invOwner'));
                $(origDrag).addClass('orig-dragging');

                // Clone this shit for dragging
                draggingItem = $(this).clone();
                AddItemToSlot(draggingItem, itemData);
                $(draggingItem).data('slot', $(this).data('slot'));
                $(draggingItem).data('invOwner', $(this).parent().data('invOwner'));
                $(draggingItem).addClass('dragging');

                $(draggingItem).css('pointer-events', 'none');
                $(draggingItem).css('left', (cursorX - offset[0]) + 'px');
                $(draggingItem).css('top', (cursorY - offset[1]) + 'px');
                $('.ui').append(draggingItem);


                if (!itemData.usable)
                    $("#use").addClass("disabled");

                if (!itemData.giveAble)
                    $("#give").addClass("disabled");

                if (!itemData.canRemove) {
                    $("#drop").addClass("disabled");
                    $("#give").addClass("disabled");
                }
            }
            dragging = true;
        }
    });

    $('.close-ui').click(function(event, ui) {
        closeInventory();
    });

    $('#search').on('keyup keydown blur', function(e) {
        SearchInventory($(this).val());
    });

    $('#search-reset').on('click', function() {
        SearchInventory('');
        $('#search').val('');
    });

    $('#use').click(function(event, ui) {
        if (dragging) {
            const itemData = $(draggingItem).find('.item').data("item");
            if (itemData.usable) {
                InventoryLog('Using ' + itemData.label + ' and Close ' + itemData.closeUi);
                $.post("http://esx_inventory/UseItem", JSON.stringify({
                    owner: $(draggingItem).parent().data('invOwner'),
                    slot: $(draggingItem).data('slot'),
                    item: itemData
                }));

                if (itemData.closeUi)
                    closeInventory();

                successAudio.play();
                EndDragging();
            } else {
                failAudio.play();
            }
        }
    });

    $("#use").mouseenter(function() {
        if (draggingItem != null && !$(this).hasClass('disabled'))
            $(this).addClass('hover');
    }).mouseleave(function() {
        $(this).removeClass('hover');
    });


    $('#inventoryOne, #inventoryTwo').on('mouseenter', '.slot', function() {
        const itemData = $(this).find('.item').data('item');
        if (itemData !== undefined) {
            $('.tooltip-div').find('.tooltip-name').html(itemData.label);

            itemData.stackable ? $('.tooltip-div').find('.tooltip-uniqueness').html("Stack Max (" + itemData.max + ")") : $('.tooltip-div').find('.tooltip-uniqueness').html("Not Stackable");
            itemData.description !== undefined ? $('.tooltip-div').find('.tooltip-desc').html('Description: ' + itemData.description) : $('.tooltip-div').find('.tooltip-desc').html("This Item Has No Information");
            itemData.weight !== undefined ? $('.tooltip-div').find('.tooltip-weight').html('Weight: ' + itemData.weight) : $('.tooltip-div').find('.tooltip-weight').hide();

            if (itemData.staticMeta !== undefined || itemData.staticMeta !== "") {
                if (itemData.type === 1)
                    $('.tooltip-div').find('.tooltip-meta').append('<div class="meta-entry"><div class="meta-key">Registered Owner</div> : <div class="meta-val">' + itemData.staticMeta.owner + '</div></div>');
                else if (itemData.itemId === 'license') {
                    $('.tooltip-div').find('.tooltip-meta').append('<div class="meta-entry"><div class="meta-key">Name</div> : <div class="meta-val">' + itemData.staticMeta.name + '</div></div>');
                    $('.tooltip-div').find('.tooltip-meta').append('<div class="meta-entry"><div class="meta-key">Issued On</div> : <div class="meta-val">' + itemData.staticMeta.issuedDate + '</div></div>');
                    $('.tooltip-div').find('.tooltip-meta').append('<div class="meta-entry"><div class="meta-key">Height</div> : <div class="meta-val">' + itemData.staticMeta.height + '</div></div>');
                    $('.tooltip-div').find('.tooltip-meta').append('<div class="meta-entry"><div class="meta-key">Date of Birth</div> : <div class="meta-val">' + itemData.staticMeta.dob + '</div></div>');
                    $('.tooltip-div').find('.tooltip-meta').append('<div class="meta-entry"><div class="meta-key">Phone Number</div> : <div class="meta-val">' + itemData.staticMeta.phone + '</div></div>');
                    $('.tooltip-div').find('.tooltip-meta').append('<div class="meta-entry"><div class="meta-key">Citizen ID</div> : <div class="meta-val">' + itemData.staticMeta.id + '-' + itemData.staticMeta.user + '</div></div>');

                    if (itemData.staticMeta.endorsements !== undefined)
                        $('.tooltip-div').find('.tooltip-meta').append('<div class="meta-entry"><div class="meta-key">Endorsement</div> : <div class="meta-val">' + itemData.staticMeta.endorsements + '</div></div>');
                } else if (itemData.itemId === 'gold')
                    $('.tooltip-div').find('.tooltip-meta').append('<div class="meta-entry"><div class="meta-key"></div> : <div class="meta-val">This Bar Has A Serial Number Engraved Into It Registered To San Andreas Federal Reserve</div></div>');
            } else
                $('.tooltip-div').find('.tooltip-meta').html("This Item Has No Information");
            $('.tooltip-div').show();
        }
    });

    $('#inventoryOne, #inventoryTwo').on('mouseleave', '.slot', function() {
        $('.tooltip-div').hide();
        $('.tooltip-div').find('.tooltip-name').html("");
        $('.tooltip-div').find('.tooltip-uniqueness').html("");
        $('.tooltip-div').find('.tooltip-meta').html("");
    });

    $("body").on("keyup", function(key) {
        if (Config.closeKeys.includes(key.which))
            closeInventory();

        if (key.which === 69)
            if (type === "trunk")
                closeInventory();
    });
});

function SearchInventory(searchVal) {
    if (searchVal !== '') {
        $.each($('#search').parent().parent().parent().find('#inventoryOne, #inventoryTwo').children(),
            function(index, slot) {
                let item = $(slot).find('.item').data('item');

                if (item != null)
                    item.label.toUpperCase().includes(searchVal.toUpperCase()) || item.itemId.includes(searchVal.toUpperCase()) ? $(slot).removeClass('search-non-match') : $(slot).addClass('search-non-match');
                else
                    $(slot).addClass('search-non-match');
            }
        );
    } else {
        $.each($('#search').parent().parent().parent().find('#inventoryOne, #inventoryTwo').children(), function(index, slot) {
                $(slot).removeClass('search-non-match');
            }
        );
    }
}


function AttemptDropInEmptySlot(origin, destination, moveQty) {
    const result = ErrorCheck(origin, destination, moveQty);
    if (result === -1) {
        $('.slot.error').removeClass('error');
        const item = origin.find('.item').data('item');

        if (item == null)
            return;

        if (moveQty > item.qty || moveQty === 0)
            moveQty = item.qty;

        if (moveQty === item.qty) {
            ResetSlotToEmpty(origin);
            item.slot = destination.data('slot');
            AddItemToSlot(destination, item);
            successAudio.play();

            InventoryLog('Moving ' + item.qty + ' ' + item.label + ' ' + ' From ' + origin.data('invOwner') + ' Slot ' + origin.data('slot') + ' To ' + destination.parent().data('invOwner') + ' Slot ' + item.slot);
            $.post("http://esx_inventory/MoveToEmpty", JSON.stringify({
                originOwner: origin.parent().data('invOwner'),
                originSlot: origin.data('slot'),
                originTier: origin.parent().data('invTier'),
                originItem: item,
                destinationOwner: destination.parent().data('invOwner'),
                destinationType: destination.find('.item').data('invType'),
                destinationSlot: item.slot,
                destinationTier: destination.parent().data('invTier'),
                destinationItem: destination.find('.item').data('item'),
            }));
            LockInventory();
        } else {
            const item2 = Object.create(item);
            item2.slot = destination.data('slot');
            item2.qty = moveQty;
            item.qty = item.qty - moveQty;
            AddItemToSlot(origin, item);
            AddItemToSlot(destination, item2);
            successAudio.play();

            InventoryLog('Empty: Moving ' + moveQty + ' ' + item.label + ' From ' + origin.data('invOwner') + ' Slot ' + item.slot + ' To ' + destination.parent().data('invOwner') + ' Slot ' + item2.slot);
            $.post("http://esx_inventory/EmptySplitStack", JSON.stringify({
                originOwner: origin.parent().data('invOwner'),
                originSlot: origin.data('slot'),
                originTier: origin.parent().data('invTier'),
                originItem: origin.find('.item').data('item'),
                destinationOwner: destination.parent().data('invOwner'),
                destinationSlot: item2.slot,
                destinationTier: destination.parent().data('invTier'),
                destinationItem: destination.find('.item').data('item'),
                moveQty: moveQty,
            }));
            LockInventory();
        }
    } else {
        failAudio.play();
        if (result === 1) {
            origin.addClass('error');
            setTimeout(function() {
                origin.removeClass('error');
            }, 1000);
            destination.addClass('error');
            setTimeout(function() {
                destination.removeClass('error');
            }, 1000);
            InventoryLog("Destination Inventory Owner Was Undefined");
        }
    }
}

function AttemptDropInOccupiedSlot(origin, destination, moveQty) {
    const result = ErrorCheck(origin, destination, moveQty);

    const originItem = origin.find('.item').data('item');
    const destinationItem = destination.find('.item').data('item');

    if (originItem === undefined || destinationItem === undefined)
        return;

    if (result === -1) {
        $('.slot.error').removeClass('error');
        if (originItem.itemId === destinationItem.itemId && destinationItem.stackable) {
            if (moveQty > originItem.qty || moveQty === 0)
                moveQty = originItem.qty;

            if (moveQty != originItem.qty && destinationItem.qty + moveQty <= destinationItem.max) {
                originItem.qty -= moveQty;
                destinationItem.qty += moveQty;
                AddItemToSlot(origin, originItem);
                AddItemToSlot(destination, destinationItem);

                successAudio.play();
                InventoryLog('Non-Empty: Moving ' + moveQty + ' ' + originItem.label + ' In ' + origin.data('invOwner') + ' Slot ' + originItem.slot + ' To ' + destination.parent().data('invOwner') + ' Slot' + destinationItem.slot);
                $.post("http://esx_inventory/SplitStack", JSON.stringify({
                    originOwner: origin.parent().data('invOwner'),
                    originTier: origin.parent().data('invTier'),
                    originSlot: originItem.slot,
                    originItem: originItem,
                    destinationOwner: destination.parent().data('invOwner'),
                    destinationSlot: destinationItem.slot,
                    destinationTier: destination.parent().data('invTier'),
                    moveQty: moveQty,
                }));
                LockInventory();
            } else {
                if (destinationItem.qty === destinationItem.max) {
                    destinationItem.slot = origin.data('slot');
                    originItem.slot = destination.data('slot');

                    ResetSlotToEmpty(origin);
                    AddItemToSlot(origin, destinationItem);
                    ResetSlotToEmpty(destination);
                    AddItemToSlot(destination, originItem);
                    successAudio.play();

                    InventoryLog('Swapping ' + originItem.label + ' In  ' + destination.parent().data('invOwner') + ' Slot ' + originItem.slot + ' With ' + destinationItem.label + ' In ' + origin.data('invOwner') + ' Slot ' + destinationItem.slot);
                    $.post("http://esx_inventory/SwapItems", JSON.stringify({
                        originOwner: origin.parent().data('invOwner'),
                        originItem: origin.find('.item').data('item'),
                        originSlot: origin.data('slot'),
                        originTier: origin.parent().data('invTier'),
                        destinationOwner: destination.parent().data('invOwner'),
                        destinationItem: destination.find('.item').data('item'),
                        destinationSlot: destination.data('slot'),
                        destinationTier: destination.parent().data('invTier'),
                    }));
                    LockInventory();
                } else if (originItem.qty + destinationItem.qty <= destinationItem.max) {
                    ResetSlotToEmpty(origin);
                    destinationItem.qty += originItem.qty;
                    AddItemToSlot(destination, destinationItem);

                    successAudio.play();
                    InventoryLog('Merging Stack Of ' + originItem.label + ' In ' + origin.data('invOwner') + ' Slot ' + originItem.slot + ' To ' + destination.parent().data('invOwner') + ' Slot' + destinationItem.slot);
                    $.post("http://esx_inventory/CombineStack", JSON.stringify({
                        originOwner: origin.parent().data('invOwner'),
                        originSlot: origin.data('slot'),
                        originTier: origin.parent().data('invTier'),
                        originItem: originItem,
                        originQty: originItem.qty,
                        destinationOwner: destination.parent().data('invOwner'),
                        destinationSlot: destinationItem.slot,
                        destinationQty: destinationItem.qty,
                        destinationTier: destination.parent().data('invTier'),
                        destinationItem: destinationItem,
                    }));
                    LockInventory();
                } else if (destinationItem.qty < destinationItem.max) {
                    const newOrigQty = destinationItem.max - destinationItem.qty;
                    originItem.qty = newOrigQty;
                    AddItemToSlot(origin, originItem);
                    destinationItem.qty = destinationItem.max;
                    AddItemToSlot(destination, destinationItem);

                    successAudio.play();

                    InventoryLog('Topping Off Stack ' + originItem.label + ' To Existing Stack In Inventory ' + destination.parent().data('invOwner') + ' Slot ' + destinationItem.slot);
                    $.post("http://esx_inventory/TopoffStack", JSON.stringify({
                        originOwner: origin.parent().data('invOwner'),
                        originSlot: origin.data('slot'),
                        originTier: origin.parent().data('invTier'),
                        originItem: originItem,
                        originQty: originItem.qty,
                        destinationOwner: destination.parent().data('invOwner'),
                        destinationSlot: destinationItem.slot,
                        destinationQty: destinationItem.qty,
                        destinationTier: destination.parent().data('invTier'),
                        destinationItem: destinationItem,
                    }));
                    LockInventory();
                } else
                    DisplayMoveError(origin, destination, "Stack At Max Items");
            }
        } else {
            destinationItem.slot = origin.data('slot');
            originItem.slot = destination.data('slot');

            ResetSlotToEmpty(origin);
            AddItemToSlot(origin, destinationItem);
            ResetSlotToEmpty(destination);
            AddItemToSlot(destination, originItem);
            successAudio.play();

            InventoryLog('Swapping ' + originItem.label + ' In ' + destination.parent().data('invOwner') + ' Slot ' + originItem.slot + ' With ' + destinationItem.label + ' In ' + origin.data('invOwner') + ' Slot ' + destinationItem.slot);
            //InventoryLog("SwapItems2 : Origin: " + origin.data('invOwner') + " Origin Slot: " + origin.data('slot') + " Destination: " + destination.parent().data('invOwner') + " Destination Slot: " + destination.data('slot'));
            $.post("http://esx_inventory/SwapItems", JSON.stringify({
                originOwner: origin.parent().data('invOwner'),
                originItem: origin.find('.item').data('item'),
                originSlot: origin.data('slot'),
                originTier: origin.parent().data('invTier'),
                destinationOwner: destination.parent().data('invOwner'),
                destinationItem: destination.find('.item').data('item'),
                destinationSlot: destination.data('slot'),
                destinationTier: destination.parent().data('invTier'),
            }));
            LockInventory();
        }

        let originInv = origin.parent().data('invOwner');
        let destInv = destination.parent().data('invOwner');
    } else {
        failAudio.play();
        if (result === 1) {
            origin.addClass('error');
            setTimeout(function() {
                origin.removeClass('error');
            }, 1000);
            destination.addClass('error');
            setTimeout(function() {
                destination.removeClass('error');
            }, 1000);
            InventoryLog("Destination Inventory Owner Was Undefined");
        }
    }
}

function ErrorCheck(origin, destination, moveQty) {
    let item;
    const originOwner = origin.parent().data('invOwner');
    const destinationOwner = destination.parent().data('invOwner');

    if (destinationOwner === undefined)
        return 1

    const sameInventory = (originOwner === destinationOwner);
    const status = -1;

    /*if (sameInventory) {} else*/ if (originOwner === $('#inventoryOne').data('invOwner') && destinationOwner === $('#inventoryTwo').data('invOwner')) {
        item = origin.find('.item').data('item');
    } else {
        item = origin.find('.item').data('item');
    }

    return status
}

function ResetSlotToEmpty(slot) {
    slot.find('.item').addClass('empty-item');
    slot.find('.item').css('background-image', 'none');
    slot.find('.item-count').html(" ");
    slot.find('.item-name').html(" ");
    slot.find('.item').removeData("item");
}

function AddItemToSlot(slot, data) {
    slot.find('.empty-item').removeClass('empty-item');
    slot.find('.item').css('background-image', 'url(\'img/items/' + data.itemId + '.png\')');

    if (data.price !== undefined && data.price !== 0)
        slot.find('.item-price').html('$' + data.price);

    slot.find('.item-count').html(data.qty + '(' + (data.weight * data.qty).toFixed(1) + ')');
    slot.find('.item-name').html(data.label);
    slot.find('.item').data('item', data);
}

function ClearLog() {
    $('.inv-log').html('');
}

function InventoryLog(log) {
    $('.inv-log').html(log + "<br>" + $('.inv-log').html());
}

function DisplayMoveError(origin, destination, error) {
    failAudio.play();
    origin.addClass('error');
    destination.addClass('error');

    if (errorHighlightTimer != null)
        clearTimeout(errorHighlightTimer);

    errorHighlightTimer = setTimeout(function() {
        origin.removeClass('error');
        destination.removeClass('error');
    }, 1000);

    InventoryLog(error);
}


let alertTimer = null;

function ItemUsed(alerts) {
    clearTimeout(alertTimer);
    $('#use-alert').hide('slide', { direction: 'left' }, 500, function() {
        $('#use-alert .slot').remove();

        $.each(alerts, function(index, data) {
            $('#use-alert').append(`<div class="slot alert-${index}""><div class="item"><div class="item-count">${data.qty}</div><div class="item-name">${data.item.label}</div></div><div class="alert-text">${data.message}</div></div>`)
                .ready(function() {
                    $(`.alert-${index}`).find('.item').css('background-image', 'url(\'img/items/' + data.item.itemId + '.png\')');
                    if (data.item.slot <= 5) {
                        $(`.alert-${index}`).find('.item').append(`<div class="item-keybind">${data.item.slot}</div>`)
                    }
                });
        });
    });

    $('#use-alert').show('slide', { direction: 'left' }, 500, function() {
        alertTimer = setTimeout(function() {
            $('#use-alert .slot').addClass('expired');
            $('#use-alert').hide('slide', { direction: 'left' }, 500, function() {
                $('#use-alert .slot.expired').remove();
            });
        }, 2500);
    });
}

let actionBarTimer = null;

function ActionBar(items, timer) {
    if ($('#action-bar').is(':visible')) {
        clearTimeout(actionBarTimer);

        for (let i = 0; i < 5; i++) {
            $('#action-bar .slot').removeClass('expired');
            if (items[i] != null) {
                $(`.slot-${i}`).find('.item-count').html(items[i].qty);
                $(`.slot-${i}`).find('.item-name').html(items[i].label);
                $(`.slot-${i}`).find('.item-keybind').html(items[i].slot);
                $(`.slot-${i}`).find('.item').css('background-image', 'url(\'img/items/' + items[i].itemId + '.png\')');
            } else {
                $(`.slot-${i}`).find('.item-count').html('');
                $(`.slot-${i}`).find('.item-name').html('NONE');
                $(`.slot-${i}`).find('.item-keybind').html(i + 1);
                $(`.slot-${i}`).find('.item').css('background-image', 'none');
            }

            actionBarTimer = setTimeout(function() {
                $('#action-bar .slot').addClass('expired');
                $('#action-bar').hide('slide', { direction: 'down' }, 500, function() {
                    $('#action-bar .slot.expired').remove();
                });
            }, timer == null ? 2500 : timer);
        }
    } else {
        $('#action-bar').html('');
        for (let i = 0; i < 5; i++) {
            if (items[i] != null) {
                $('#action-bar').append(`<div class="slot slot-${i}"><div class="item"><div class="item-count">${items[i].qty}</div><div class="item-name">${items[i].label}</div><div class="item-keybind">${items[i].slot}</div></div></div>`);
                $(`.slot-${i}`).find('.item').css('background-image', 'url(\'img/items/' + items[i].itemId + '.png\')');
            } else {
                $('#action-bar').append(`<div class="slot slot-${i}" data-empty="true"><div class="item"><div class="item-count"></div><div class="item-name">NONE</div><div class="item-keybind">${i + 1}</div></div></div>`);
                $(`.slot-${i}`).find('.item').css('background-image', 'none');
            }
        }

        $('#action-bar').show('slide', { direction: 'down' }, 500, function() {
            actionBarTimer = setTimeout(function() {
                $('#action-bar .slot').addClass('expired');
                $('#action-bar').hide('slide', { direction: 'down' }, 500, function() {
                    $('#action-bar .slot.expired').remove();
                });
            }, timer == null ? 2500 : timer);
        });
    }
}

let usedActionTimer = null;

function ActionBarUsed(index) {
    clearTimeout(usedActionTimer);

    if ($('#action-bar .slot').is(':visible')) {
        $(`.slot-${index - 1}`).data('empty') != null ? $(`.slot-${index - 1}`).addClass('empty-used') : $(`.slot-${index - 1}`).addClass('used');

        usedActionTimer = setTimeout(function() {
            $(`.slot-${index - 1}`).removeClass('used');
            $(`.slot-${index - 1}`).removeClass('empty-used');
        }, 1000)
    }
}

function LockInventory() {
    locked = true;
    $('#inventoryOne').addClass('disabled');
    $('#inventoryTwo').addClass('disabled');
}

function UnlockInventory() {
    locked = false;
    $('#inventoryOne').removeClass('disabled');
    $('#inventoryTwo').removeClass('disabled');
}

function setupweight(items, invtowener) {
    if (invtowener === 'invnetory1') {
        playerWeight = 0
        playerMoney = 0
        for (const [key, value] of Object.entries(items)) {
            playerWeight = playerWeight + (value.weight * value.qty)
            if (value.id === 'cash')
                playerMoney = value.qty
        }
    } else {
        secondWeight = 0
        for (const [key, value] of Object.entries(items))
            secondWeight = secondWeight + (value.weight * value.qty)
    }
}
