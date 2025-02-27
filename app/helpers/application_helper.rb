module ApplicationHelper
  def card(label, value)
    %(
      <div class="card bg-light mb-2">
        <div class="card-body p-2 text-center">
          <div class="small text-muted">#{label}</div>
          <div class="fw-bold">#{value}</div>
        </div>
      </div>
    ).html_safe
  end
end

