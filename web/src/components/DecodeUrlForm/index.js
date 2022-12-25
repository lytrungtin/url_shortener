// @flow
import React, { Component } from 'react';
import { Field, reduxForm } from 'redux-form';
import Errors from '../Errors';

type Props = {
  handleSubmit: () => void,
  onSubmit: () => void,
  submitting: boolean,
  errors: any,
}

class DecodeUrlForm extends Component {
  props: Props

  handleSubmit = data => this.props.onSubmit(data);

  render() {
    const { handleSubmit, submitting, errors } = this.props;

    return (
      <form onSubmit={handleSubmit(this.handleSubmit)} className="form-inline">
        <div className="row">
          <div className="form-group col-sm-12">
            <div className="input-group">
              <Field
                name="shortened_url"
                placeholder="What's URL for decoding?"
                component="textarea"
                className="form-control"
                style={{ width: '100%' }}
              />
              <div className="input-group-btn">
                  <button type="submit" className="btn btn-primary" disabled={submitting}>
                    {submitting ? 'Decoding...' : 'Decode'}
                  </button>
              </div>
            </div>
            <Errors name="shortened_url" errors={errors} />
          </div>
        </div>
      </form>
    );
  }
}

const validate = (values) => {
  const errors = {};
  if (!values.shortened_url) {
    errors.message = 'Required';
  }
  return errors;
};

export default reduxForm({
  form: 'decodeUrl',
  validate,
})(DecodeUrlForm);
