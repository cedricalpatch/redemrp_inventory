function createObjectBox(object){
    const box = document.createElement("div");
    box.setAttribute('class', 'item');
    document.getElementsByClassName(`box${object.box}`)[0].appendChild(box);

    const boxContent = document.createElement("div");
    box.appendChild(boxContent);
    boxContent.setAttribute('class', 'item-content');
    boxContent.setAttribute('objectId', object.id);
    boxContent.setAttribute('onmouseleave', 'hideSlider(this)');
    boxContent.setAttribute('oncontextmenu', `cloneBox(${object.id})`);

    const mainContent = document.createElement("div");
    mainContent.setAttribute('class', 'item-content-main');
    mainContent.style.backgroundImage = `url("${object.imgsrc}")`;
    boxContent.appendChild(mainContent);

    const sliderBox = document.createElement("div");
    boxContent.appendChild(sliderBox);
    sliderBox.setAttribute('class', 'item-content-footer');
    sliderBox.style.display = 'none';

    const slider = document.createElement("input");
    slider.setAttribute('type', 'range');
    slider.setAttribute('min', 1);
    slider.setAttribute('max', object.maxAmount);
    slider.setAttribute('value', object.amount);
    slider.style.width = '90%';
    slider.setAttribute('oninput', `setObjectAmount(${object.id}, this.value)`);
    sliderBox.appendChild(slider);
    
    const amountBox = document.createElement("div");
    boxContent.appendChild(amountBox);
    amountBox.setAttribute('class', 'item-content-footer');
    amountBox.innerHTML = object.amount;
    amountBox.setAttribute('onmouseenter', 'showSlider(this)');

    return box;
}

function showSlider(amountBox){
    sliderBox = amountBox.parentElement.children[1];
    mainBox = amountBox.parentElement.firstChild;

    mainBox.style.filter = 'blur(5px)';

    sliderBox.style.display = 'block';
    amountBox.setAttribute('class', 'item-content-amount-moved');
}

function hideSlider(boxContent){
    sliderBox = boxContent.children[1];
    amountBox = boxContent.lastChild;
    mainBox = boxContent.firstChild;

    mainBox.style.filter = 'blur(0)';
    
    amountBox.setAttribute('class', 'item-content-footer');

    sliderBox.style.display = 'none';
}

function cloneBox(id){
    object = getObjectById(id);

    if(object.amount <= 1) return;

    neighbour = getObjectsByNameAndMeta(object.name, object.meta).find( obj => obj.box == object.box && obj.id != id);
    setObjectAmount(id, object.amount - 1, false);

    if(neighbour) setObjectAmount(neighbour.id, neighbour.amount + 1, false);
    else return addObject({name: object.name, amount: 1, imgsrc: object.imgsrc, box: object.box, meta: object.meta});
}

function addObject({name = 'noname', amount = 1, imgsrc = 'items/tomahawk.png', box = 0, meta = ""}){
    id = objects.length ? objects[objects.length - 1].id + 1 : 1;

    obj = {
        id: id,
        name: name,
        meta: meta,
        amount: amount,
        imgsrc: imgsrc,
        box: box,
    };
    objects.push(obj);
    grids[parseInt(box)].add(createObjectBox(obj))[0]._id = id;
    manageAmountSum(name, meta);
    return obj;
}

function getObjectById(id){
    return objects.find(obj => obj.id == id);
}

function getObjectsByNameAndMeta(name, meta){
    return objects.filter(obj => obj.name == name && obj.meta == meta);
}

function getAmountSum(name, meta){
    return getObjectsByNameAndMeta(name, meta).reduce((sum, {amount}) => sum + amount, 0);
}

function manageAmountSum(name, meta){
    sum = getAmountSum(name, meta);
    getObjectsByNameAndMeta(name, meta).forEach(({ id }) => getObjectHTML(id).children[1].firstChild.setAttribute('max', sum));
}

function getObjectHTML(objectId){
    return document.querySelector(`[objectId='${objectId}']`);
}

function setObjectAmount(id, amount, affectOnOthers = true){
    if(amount <= 0) {
        removeObjects([getObjectById(id)]);
        return;
    }
    object = getObjectById(id);
    difference = parseInt(amount) - object.amount;
    
    object.amount = parseInt(amount);
    boxContent = getObjectHTML(id);
    boxContent.lastChild.innerHTML = amount;
    boxContent.children[1].firstChild.value = amount;
    
    if(difference == 0 || !affectOnOthers) return;
    if (getObjectsByNameAndMeta(object.name, object.meta).length == 1) {
        addObject({name: object.name, meta: object.meta, amount: -difference, imgsrc: object.imgsrc, box: object.box});
        return;
    }

    for(const destinationBox of objectsMoveDirections[object.box]){
        destinationObjects = getObjectsByNameAndMeta(object.name, object.meta).filter( obj => obj.box == destinationBox && obj.id != id);

        for(const destinationobject of destinationObjects){
            if(destinationobject.amount >= difference ){
                setObjectAmount(destinationobject.id, destinationobject.amount - difference, false);
                return;
            } else {
                difference -= destinationobject.amount;
                setObjectAmount(destinationobject.id, 0, false);
            }
        } 
    }
}

function getObjectsFromBox(box_nr){
    return objects.filter(({box}) => box == box_nr);
}

function onDragFinished(data){
    //get dragged object
    draggedObject = getObjectById(data.item._id);
    //get all repeated elements
    repeats = getObjectsFromBox(data.toGrid._id - 1).filter( ({name, meta}) => name == draggedObject.name && meta == draggedObject.meta);
    //add amount of objects from this box
    repeatsAmount = repeats.reduce((sum, {amount}) => sum + amount, 0);
    setObjectAmount(data.item._id, draggedObject.amount + repeatsAmount, false);
    //set new box value to object
    getObjectById(data.item._id).box = data.toGrid._id - 1;
    //remove all repeats
    removeObjects(repeats);
}       

function removeObjects(arrayOfObjects){
    arrayOfObjects.forEach(obj => {
        //Remove from grid
        grids[parseInt(obj.box)].remove(grids[parseInt(obj.box)].getItems().find(({ _id }) => _id == obj.id));
        //Delete HTML element
        box = getObjectHTML(obj.id).parentElement;
        box.parentElement.removeChild(box);
        //Remove from objects array
        objects = objects.filter(obj => !arrayOfObjects.find(el => el.id == obj.id))
    })
}

const objectsMoveDirections = [[0, 1, 2], [1, 0, 2], [2, 1, 0]];

let objects = [];
hide();
let objectsIn = null;
var secondInventoryId = -1

var grids = [   new Muuri('.box0', {dragEnabled: true, dragSort: () => grids, dragStartPredicate: {handle: '.item-content-main, .item-content-amount-moved'}}).on('send', data => onDragFinished(data)), 
                new Muuri('.box1', {dragEnabled: true, dragSort: () => grids, dragStartPredicate: {handle: '.item-content-main, .item-content-amount-moved'}}).on('send', data => onDragFinished(data)), 
                new Muuri('.box2', {dragEnabled: true, dragSort: () => grids, dragStartPredicate: {handle: '.item-content-main, .item-content-amount-moved'}}).on('send', data => onDragFinished(data))];


function hide(){
    document.body.style.visibility = 'hidden';
}

function show(left = true, middle = false, right = false){
    document.body.style.visibility = 'inherit';
    document.getElementsByClassName('box0')[0].style.visibility = (left) ? 'inherit' : 'hidden';
    document.getElementsByClassName('box1')[0].style.visibility = (middle) ? 'inherit' : 'hidden';
    document.getElementsByClassName('box2')[0].style.visibility = (right) ? 'inherit' : 'hidden';
}

function getItems(data, secondInventory){
    secondInventoryId = secondInventory
      objectsIn = data;
      removeObjects(objects);
      data.forEach(item => addObject(item));
     // console.log(Object.keys(data[0]));
     // console.log(data[0].imgsrc);
     //objectsIn = [{ name: 'pistolet', amount: 10, imgSrc: 'items/tomahawk.png', box: 0, meta: 'celny bardzo'}];/
}

function sendItems(){
    $.post('http:/redemrp_inventory/sendItems',JSON.stringify({objects:objects, id:secondInventoryId}),);
    console.log(JSON.stringify(objects));
    console.log(JSON.stringify([secondInventoryId]));
}

$(document).keyup(function(e) {
    if (e.key === "Escape" || e.key === 'e') {  //hide eq
        
        sendItems();
        hide();
        $.post('http:/redemrp_inventory/close');
   }
});
