## Copyright 2010 Tim Rayner, University of Cambridge
## 
## This file is part of ClinStudy::Web.
## 
## ClinStudy::Web is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 2 of the License, or
## (at your option) any later version.
## 
## ClinStudy::Web is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with ClinStudy::Web.  If not, see <http://www.gnu.org/licenses/>.
##
## $Id$

csFindAssays <- function(cell.type, platform, batch.name, study,
                         diagnosis, timepoint, trial.id, uri, .opts=list(), cred=NULL ) {

    stopifnot( ! missing(uri) )

    cond  <- list()
    attrs <- list(join=c())

    if ( ! missing(cell.type) ) {
        cond       <- append(cond, list('cell_type_id.value'=cell.type))
        attrs$join <- append(attrs$join, list(list(channels=list(sample_id='cell_type_id'))))
    }

    if ( ! missing(diagnosis) ) {   # FIXME this needs to use only the latest diagnosis.
        cond       <- append(cond, list('condition_name_id.value'=diagnosis))
        attrs$join <- append(attrs$join, list(list(channels=list(
                                                     sample_id=c(list(
                                                       visit_id=list(
                                                         patient_id=list(
                                                           diagnoses='condition_name_id'))))))))
    }

    if ( ! missing(study) ) {
        cond       <- append(cond, list('type_id.value'=study))
        attrs$join <- append(attrs$join, list(list(channels=list(
                                                     sample_id=list(
                                                       visit_id=list(
                                                         patient_id=list(
                                                           studies='type_id')))))))
    }

    if ( ! missing(timepoint) ) {
        cond       <- append(cond, list('nominal_timepoint_id.value'=timepoint))
        attrs$join <- append(attrs$join, list(list(channels=list(
                                                     sample_id=list(
                                                       visit_id='nominal_timepoint_id')))))
    }

    if ( ! missing(trial.id) ) {
        cond       <- append(cond, list('patient_id.trial_id'=trial.id))
        attrs$join <- append(attrs$join, list(list(channels=list(
                                                     sample_id=list(
                                                       visit_id='patient_id')))))
    }    

    if ( ! missing(platform) ) {
        cond       <- append(cond, list('platform_id.value'=platform))
        attrs$join <- append(attrs$join, list(list(assay_batch_id='platform_id')))
    }

    if ( ! missing(batch.name) ) {
        cond       <- append(cond, list('assay_batch_id.name'=batch.name))
        attrs$join <- append(attrs$join, 'assay_batch_id')
    }

    assays <- csJSONQuery(resultSet='Assay',
                          condition=cond,
                          attributes=attrs,
                          uri=uri,
                          .opts=.opts,
                          cred=cred)

    return(assays)
}
