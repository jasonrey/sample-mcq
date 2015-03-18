$ ->
    # Sample answers
    # Standardise answer to be always array regardless of the number of answers
    master =
        "1": [1]
        "2": [5]
        "3": [8, 9]
    checkAnswer = (data) ->
        dfd = $.Deferred()

        answers = master[data.id]

        response = state: true

        response.state = false if answers.length isnt data.answers.length

        for a in answers
            response.state = false if a not in data.answers

        if response.state is false
            response.answers = answers

        dfd.resolve response

        return dfd

    items = $ "[data-type='mcq']"

    return if items.length is 0

    for item in items
        item = $ item

        item.on "click", ".option", (event) ->
            option = $ @

            block = $ event.delegateTarget

            if block.hasClass "disabled"
                return

            allowed = parseInt block.data "allowed"

            if allowed is 1
                option.siblings().removeClass "active"
                option.addClass "active"

                # Immediately check
                block.trigger "check"
            else
                if option.hasClass "active"
                    option.removeClass "active"
                    return

                actives = block.find ".option.active"

                if actives.length >= allowed
                    return

                option.addClass "active"

        item.on "click", ".check", (event) ->
            button = $ @
            block = $ event.delegateTarget
            block.trigger "check"

        item.on "check", (event) ->
            block = $ @

            if block.hasClass "disabled"
                return

            id = block.data "id"
            allowed = block.data "allowed"

            actives = block.find ".option.active"

            if actives.length < allowed
                return

            block.addClass "disabled"

            answers = ($(active).data "id" for active in actives)

            # Actual ajax call will have response.status and response.data

            checkAnswer(
                id: id
                answers: answers
            ).done (response) ->
                # (bool) response.state True if overall correct
                # (array) response.answers The answers

                if response.state is true
                    actives.addClass "correct"
                else
                    actives.addClass "wrong"

                    for a in response.answers
                        option = block.find ".option[data-id=" + a + "]"

                        option.addClass "correct"
                        option.removeClass "wrong" if option.hasClass "active"