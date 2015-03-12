$ ->
    # Sample answers
    # Standardise answer to be always array regardless of the number of answers
    answers =
        "1": [1]
        "2": [5]
        "3": [8, 9]
    verifyAnswer = (data) ->
        answer = answers[data.id]

        return false if answer.length isnt data.answer.length

        for a in answer
            return false if a not in data.answer

        return true
    checkAnswer = (data) ->
        response =
            result: verifyAnswer data

        if response.result is false
            response.answer = answers[data.id]

        return response

    item = $ ".item"

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

        answer = []
        answer.push $(active).data "id" for active in actives

        # Actual ajax call will have response.status and response.data

        data = checkAnswer(
            id: id
            answer: answer
        )

        # (bool) data.result True for correct
        # (array) data.answer

        if data.result is true
            actives.addClass "correct"
        else
            actives.addClass "wrong"

            for a in data.answer
                option = block.find ".option[data-id=" + a + "]"

                option.addClass "correct"
                option.removeClass "wrong" if option.hasClass "active"