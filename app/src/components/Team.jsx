import React, { Component } from "react";

export class Team extends Component {
  render() {
    return (
      <div id="team" className="text-center">
        <div className="container">
          <div className="col-md-8 col-md-offset-2 section-title">
            <h2>Meet the Team</h2>
            <p>
              We are a small team of individuals who are passionate about creating custom cloud solutions to solve any business's data problems.
            </p>
          </div>
            {this.props.data
              ? this.props.data.map((d, i) => (
                <div id="row">
                  <div  key={`${d.name}-${i}`} className="col-md-8 col-md-offset-2 team">
                    <div className="thumbnail">
                      {" "}
                      <img src={d.img} alt="..." className="team-img" />
                      <div className="caption">
                        <h4>{d.name}</h4>
                        <p>{d.job}</p>
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

export default Team;
