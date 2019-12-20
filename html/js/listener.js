$(function(){
	window.onload = (e) => {
		window.addEventListener('message', (event) => {
			console.log("par2ap");
			switch (event.data.type){
				case 1:
					getItems(event.data.items, event.data.secondInventory);
					console.log(event.data.items)
					console.log("parap");
					show(event.data.showLeft, event.data.showMiddle , event.data.showRight);
				break;
				case 2:
					hide();
				break;
				default:
					hide();
			}
			console.log("wuwuw");
		});
	};
});
