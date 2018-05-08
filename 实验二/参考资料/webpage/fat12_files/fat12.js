String.prototype.format = function (o) {
    return this.replace(/{([^{}]*)}/g,
        function (a, b) {
            var r = o[b];
            return typeof r === 'string' || typeof r === 'number' ? r : a;
        }
    );
};


function hash(x) {
    return CryptoJS.SHA1(x.toString());
}


function onInputBoxChanged(inputBox) {
    var userInput = inputBox.val();
    var expected = inputBox.attr('solution-hash');

    var caseSensitive = inputBox.attr('case-sensitive') == 'yes';
    if ( !caseSensitive )
    {
        userInput = userInput.toUpperCase();
    }

    var userInputHash = hash(userInput);
    var isCorrect = userInputHash.toString() === expected;

    if ( isCorrect ) {
        inputBox.addClass('correct');
    }
    else {
        inputBox.removeClass('correct');
    }
}

function setup() {
    setupToc();
    decorateBoxes();

    $(".input-box").each( function() {
        var box = $(this);

        box.change( function() {
            onInputBoxChanged(box);
        } );
    } );
}

function setupToc()
{
    function processTocSection(section)
    {
        var header = section.find("h2").html();
        var id = section.attr('id');

        $('#toc ul').append("<li><a href='#{id}'>{header}</a></li>".format( { header: header,
                                                                              id: id } ) );
    }

    $(".toc-elt").each( function ()
                        {
                            processTocSection( $(this) );
                        } );
}

function decorateBoxes()
{
    function decorateBox(div)
    {
        var contents = div.html();
        var category = div.attr('data-category');
        var newContents = '<div class="box-category">{category}</div>{contents}'.format( { contents: contents, category: category } );

        div.html(newContents);
    }

    $("div.boxed").each( function ()
                         {
                             decorateBox( $(this) );
                         } );
}


$( setup );
