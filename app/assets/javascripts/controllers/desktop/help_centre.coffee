class TheArticle.HelpCentre extends TheArticle.mixOf TheArticle.DesktopPageController, TheArticle.PageTransitions

	@register window.App
	@$inject: [
	  '$scope'
	  '$http'
	  '$compile'
	  '$timeout',
	  '$ngConfirm'
	]

	init: ->
		@bindEvents()

	bindEvents: =>
		$('[data-section-id]').on 'click', (e) =>
			$('#mobile_return').hide()
			e.preventDefault()
			$('[data-section-id]').removeClass('active')
			$('.question_list').hide()
			$('.answer').hide()
			$("[data-outcome-show]").hide()
			$('.feedback_question').show()
			$('.feedback_answer').show()
			$clicked = $(e.currentTarget)
			$clicked.addClass('active')
			sectionId = $clicked.data('section-id')
			$("#question_list_#{sectionId}").show()

		$('[data-question-id]').on 'click', (e) =>
			e.preventDefault()
			$('.answer').hide()
			$("[data-outcome-show]").hide()
			$clicked = $(e.currentTarget)
			questionId = $clicked.data('question-id')
			$('.question_list').hide()
			$("#answer_#{questionId}").show()

		$('[data-back-to]').on 'click', (e) =>
			e.preventDefault()
			$('.answer').hide()
			$("[data-outcome-show]").hide()
			$('.feedback_question').show()
			$('.feedback_answer').show()
			$clicked = $(e.currentTarget)
			sectionId = $clicked.data('back-to')
			$("#question_list_#{sectionId}").show()

		$('[data-reset]').on 'click', (e) =>
			e.preventDefault()
			$('.answer').hide()
			$("[data-outcome-show]").hide()
			$('.feedback_question').hide()
			$('.feedback_answer').hide()
			$('.question_list').hide()
			$clicked = $(e.currentTarget)
			sectionId = $clicked.data('back-to')
			$("#question_list_#{sectionId}").show()
			$('#mobile_return').show()

		$('[data-feedback-id]').on 'click', (e) =>
			e.preventDefault()
			$clicked = $(e.currentTarget)
			questionId = $clicked.data('feedback-id')
			outcome = $clicked.data('feedback-outcome')
			$.getJSON "/help-feedback/#{questionId}/#{outcome}", (response) =>
				$('.feedback_question').hide()
				$('.feedback_answer').hide()
				$("[data-outcome-show=#{outcome}]").show()

		$('[data-toggle=collapser]').on 'click', (e) =>
			e.preventDefault()
			$clicked = $(e.currentTarget)
			$('[data-toggle=collapser]').removeClass('active')
			$clicked.addClass('active')
			target = $clicked.attr('href')
			$('.accordion-body').slideUp().removeClass('active')
			$(target).slideDown().addClass('active')


TheArticle.ControllerModule.controller('HelpCentreController', TheArticle.HelpCentre)