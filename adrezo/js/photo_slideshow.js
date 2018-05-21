//@Author: Yann POSTEC
document.onkeydown = checkKey;
var controls = document.querySelectorAll('.controls');
for(var i=0; i<controls.length; i++){
	controls[i].style.display = 'inline-block';
}
var slides = document.querySelectorAll('#slides .slide');
var currentSlide = 0;
var slideInterval = setInterval(nextSlide,SlideTime);
function nextSlide(){
	goToSlide(currentSlide+1);
}
function previousSlide(){
	goToSlide(currentSlide-1);
}
function goToSlide(n){
	slides[currentSlide].className = 'slide';
	currentSlide = (n+slides.length)%slides.length;
	slides[currentSlide].className = 'slide showing';
}
var playing = true;
var pauseButton = document.getElementById('pause');
function pauseSlideshow(){
	pauseButton.innerHTML = '&#9658;';
	playing = false;
	clearInterval(slideInterval);
}
function playSlideshow(){
	pauseButton.innerHTML = '&#10074;&#10074;';
	playing = true;
	slideInterval = setInterval(nextSlide,SlideTime);
}
pauseButton.onclick = function(){
	if(playing){ pauseSlideshow(); }
	else{ playSlideshow(); }
};
var next = document.getElementById('next');
var previous = document.getElementById('previous');
next.onclick = function(){
	pauseSlideshow();
	nextSlide();
};
previous.onclick = function(){
	pauseSlideshow();
	previousSlide();
};
function checkKey(e) {
	if (e.keyCode === 37) {
		pauseSlideshow();
		previousSlide();
	}
	if (e.keyCode === 39) {
		pauseSlideshow();
		nextSlide();
	}
}
