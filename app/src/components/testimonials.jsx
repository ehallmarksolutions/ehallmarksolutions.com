import React, { Component } from "react";

export class testimonials extends Component {
  render() {
    return (
      <div id="testimonials">
        <div className="container">
          <div className="section-title text-center">
            <h2>What our clients say</h2>
          </div>
            {this.props.data
              ? this.props.data.map((d, i) => (
                <div className="row">
                  <div key={`${d.name}-${i}`} className="col-md-8 col-md-offset-2">
                    <div className="testimonial">
                      <div className="testimonial-image">
                        {" "}
                        {d.img ? <img src={d.img} alt="" /> : <span></span>} {" "}
                      </div>
                      <div className="testimonial-content">
                        <p>"{d.text}"</p>
                        <div className="testimonial-meta"> - {d.name} </div>
                      </div>
                    </div>
                  </div>
                </div>
              ))
            : "loading"}
        </div>
      </div>
    );
  }
}

export default testimonials;
