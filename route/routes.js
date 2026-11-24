const controller = require('../controller/controller');
const express = require('express');
const router = express.Router();

router.get('/stats', controller.getStats);

router.route('/books')
	.get(controller.getBooks)
	.post(controller.createBook);
router.delete('/books/:id', controller.deleteBook);

router.route('/readers')
	.get(controller.getReaders)
	.post(controller.createReader);
router.delete('/readers/:id', controller.deleteReader);

router.route('/loans')
	.get(controller.getLoans)
	.post(controller.createLoan);
router.delete('/loans/:id', controller.returnLoan);

router.use(controller.handleError);

module.exports = router;
