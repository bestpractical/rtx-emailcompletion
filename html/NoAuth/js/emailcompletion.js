function initPage() {
    addAutoComplete();
} // initPage

// we need two Arrays :
// one for input with multiple email address allowed
var multipleCompletion = new Array("Requestors", "Cc", "AdminCc", "WatcherAddressEmail[123]", "UpdateCc", "UpdateBcc");

// and one for input with only one email address allowed
var uniqueCompletion   = new Array("(Add|Delete)Requestor", "(Add|Delete)Cc", "(Add|Delete)AdminCc");

var Regexp         = new RegExp('^(' + multipleCompletion.concat(uniqueCompletion).join('|') + ')$');
var multipleRegexp = new RegExp('^(' + multipleCompletion.join('|') + ')$');

function findRegexpInArray(string) {
    for (var i = 0; i < InputNames.length; i++) {
	regexp = new RegExp('^' + InputNames[i]+'$');
	if (string.match(regexp)) {
	    return 1;
	}
    }
}

function addAutoComplete() {
    var inputs = document.getElementsByTagName("input");

    for (var i = 0; i < inputs.length; i++) {
	var input = inputs[i];
	var inputName = input.getAttribute("name");

	if (! inputName)
	    continue;

	// only input's names defined in global vars at the beginning
	// are concerned
	if ( ! inputName.match(Regexp) )
	    continue;

	// if multiple email address allowed we add an tokens option
	// to Autocompleter
	var options = '';
	if (inputName.match(multipleRegexp))
	    options = "tokens: ','"

	input.setAttribute("id", inputName);

	// FIXME "je suis la"
	var div = '<div class="autocomplete" id="' + inputName + '_to_auto_complete">je suis la</div>';
	div += '<script type="text/javascript">new Ajax.Autocompleter(\'' + inputName;
	div += "', '" + inputName + "_to_auto_complete', '<%$RT::WebPath%>/Ajax/Email\', {" + options + "})</script>";

	// use prototype to add the div after input
	new Insertion.After(inputName,div);
    }

} //addAutoComplete

Event.observe(window, 'load', initPage);
