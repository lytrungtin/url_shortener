import React, { Component } from 'react';
import { Field, reduxForm } from 'redux-form';
import Errors from '../Errors';
import Messages from '../Messages';

type Props = {
  onEncode: () => void,
  onDecode: () => void,
  submitting: boolean,
  errors: any,
  messages: any,
}

class UrlForm extends Component {
  constructor(props) {
    super(props);
    this.state = {
      fieldValue: '',
    };
  }

  handleEncode = () => {
    const data = { url: { original_url: this.state.fieldValue } }; 
    this.props.onEncode(data);
  }

  handleDecode = () => {
    const data = { url: { shortened_url: this.state.fieldValue } }; 
    this.props.onDecode(data);
  }
  
  handleInputChange = (event) => {
    this.setState({ fieldValue: event.target.value });
  }

  render() {
    const { submitting, errors, messages } = this.props;

    return (
      <form className="form-inline">
        <div className="row">
          <div className="form-group col-sm-12">
            <div className="input-group">
              <Field
                name="field_value"
                placeholder="Link nào đâu?"
                component="textarea"
                className="form-control"
                style={{ width: '100%' }}
                value={this.state.fieldValue}
                onChange={this.handleInputChange}
              />
            </div>
            <div className="input-group-btn">
              <button type="button" className="btn btn-primary" disabled={submitting} onClick={this.handleEncode}>
                {submitting ? 'Đang rút gọn...' : 'Rút gọn link'}
              </button>
              <button type="button" className="btn btn-primary" disabled={submitting} onClick={this.handleDecode} style={{'float': 'right'}}>
                {submitting ? 'Đang trả về link đầy đủ...' : 'Trả về link đầy đủ'}
              </button>
            </div>
            <Errors errors={errors} />
            <Messages messages={messages} />
          </div>
        </div>
      </form>
    );
  }
}

export default reduxForm({
  form: 'Url'
})(UrlForm);
