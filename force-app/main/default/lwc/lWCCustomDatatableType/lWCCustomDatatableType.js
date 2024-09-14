/* File Name: LWCCustomDatatabletype 
 * Description: Generic table table component to show picklist in lightning data table in lwc
 * Author: Rajat Kumar Mishra
 * Version: 1.0
 * History:
 * Date            Author                 Comment
 * Oct-26-2023     Rajat Kumar Mishra     Initial version
 *
 */
import LightningDatatable from 'lightning/datatable';
import sPEN_picklistColumn from './sPEN_picklistColumn.html';
import sPEN_pickliststatic from './sPEN_pickliststatic.html';
 
export default class LWCCustomDatatableType extends LightningDatatable {
    static customTypes = {
        picklistColumn: {
            template: sPEN_pickliststatic,
            editTemplate: sPEN_picklistColumn,
            standardCellLayout: true,
            typeAttributes: ['label', 'placeholder', 'options', 'value', 'context', 'variant','name']
        }
    };
}